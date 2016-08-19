<template>
  <x-frame :gutter-size="5">
    <menu slot="menu" event-prefix="cmd-"></menu>
    <tree class="border"
          slot="left" v-ref:tree-view></tree>
    <component slot="right"
               :is="rightView"
               v-ref:right-view></component>
    <console slot="bottom" :id="'hugo'"></console>
    <state slot="state"></state>
  </x-frame>
</template>

<script>
  import _ from 'lodash'
  import {rpc} from './lib/ws'
  import fileTypes from './lib/fileTypes'
  import fileManager from './lib/fileManager'
//  import store from './vuex/store'
  import XFrame from './components/XFrame'
  import BaseCodeMirror from './components/CodeMirror'
  import MarkdownPreviewer from './components/MarkdownPreviewer'
  import BaseEditorManager from './components/EditorManager'
  import BaseTree from './components/Tree'
  import BaseMenu from './components/Menu'
  import Console from './components/Console'
  import State from './components/State'
  import swal from './lib/vue-sweetalert'

  function extend (base, option) {
    const ret = _.clone(base)
    for (let key in option) {
      if (_.isFunction(option[key])) {
        ret[key] = option[key]
      } else {
        ret[key] = _.extend(ret[key], option[key])
      }
    }
    return ret
  }

  // 配置CoreMirror
  import '../../node_modules/codemirror/addon/search/search'
  import '../../node_modules/codemirror/addon/search/match-highlighter'
  import '../../node_modules/codemirror/addon/dialog/dialog.css'
  import '../../node_modules/codemirror/mode/meta'
  import '../../node_modules/codemirror/mode/htmlmixed/htmlmixed'
  import '../../node_modules/codemirror/mode/gfm/gfm'
  import '../../node_modules/codemirror/mode/toml/toml'
  const CodeMirror = extend(BaseCodeMirror, {
    methods: {
      getConfig () {
        return {
          lineNumbers: true,
          extraKeys: {
            'Alt-F': 'findPersistent'
          },
          highlightSelectionMatches: {
            showToken: /\w/,
            annotateScrollbar: true
          }
        }
      }
    }
  })

  // 配置编辑器
  const EditorManager = extend(BaseEditorManager, {
    methods: {
      doSave (data) {
        fileManager.save(
          data.path,
          data.draft,
          function () {
            data.content = data.draft
            data.draft = null
            console.log('save done!')
          },
          function () {
            console.log('save failed!')
          })
      },
      getEditorComponent (path) {
        if (/\.(html|htm|xml|json|js|css|md|toml)$/i.test(path)) {
          return 'CodeMirror'
        }
      },
      getPreviewerComponent (path) {
        if (/\.md$/i.test(path)) {
          return 'MarkdownPreviewer'
        }
      },
      getContent (path, done) {
        if (_.isUndefined(this.getEditorComponent(path))) {
          done('')
        } else {
          fileManager.cat(path, done)
        }
      }
    },
    components: {
      CodeMirror,
      MarkdownPreviewer
    }
  })

  // 配置Tree
  function treeMenus (node) {
    const data = node.original
    return {
      open: {
        label: '打开',
        _disabled: data.type === '.'
      },
      mkDir: {
        label: '新建目录',
        _disabled: data.type !== '.'
      },
      add: {
        label: '新建文件'
      },
      rename: {
        label: '重命名'
      },
      del: {
        label: '删除'
      }
    }
  }
  const Tree = extend(BaseTree, {
    methods: {
      menuClick (evt) {
        const self = this
        switch (evt.action) {
          case 'open':
            this.$dispatch('cmd-file-open', evt.jstree.get_path(evt.node).join('/'))
            break
          case 'mkDir':
            swal({
              title: '新建目录',
              text: '请输入目录名:',
              type: 'input',
              inputType: 'text',
              showCancelButton: true,
              closeOnConfirm: false,
              showLoaderOnConfirm: true
            }, function (dirname) {
              if (dirname !== false) {
                const paths = evt.jstree.get_path(evt.node)
                paths.push(dirname)
                const path = paths.join('/')
                fileManager.mkdir(
                  path,
                  function () {
                    swal('创建成功', '目录创建成功!', 'success')
                    self.$dispatch('cmd-refresh-tree')
                  },
                  function () {
                    swal.showInputError('创建目录失败.')
                  })
              }
            })
            break
          case 'add':
            swal({
              title: '新建文件',
              text: '请输入文件名:',
              type: 'input',
              inputType: 'text',
              showCancelButton: true,
              closeOnConfirm: false,
              showLoaderOnConfirm: true
            }, function (filename) {
              if (filename !== false) {
                const paths = evt.jstree.get_path(evt.node)
                if (evt.data.type !== '.') {
                  paths.pop()
                }
                paths.push(filename)
                const path = paths.join('/')
                fileManager.save(
                  path,
                  '',
                  function () {
                    swal('创建成功', '文件创建成功!', 'success')
                    self.$dispatch('cmd-file-open', path)
                    self.$dispatch('cmd-refresh-tree')
                  },
                  function () {
                    swal.showInputError('创建文件失败.')
                  })
              }
            })
            break
          case 'rename':
            {
              const paths = evt.jstree.get_path(evt.node)
              const oldFileName = paths.pop()
              const path = paths.join('/')
              swal({
                title: '文件名重命名',
                text: '请输入新的文件名:',
                type: 'input',
                inputType: 'text',
                inputValue: oldFileName,
                showCancelButton: true,
                closeOnConfirm: false,
                showLoaderOnConfirm: true
              }, function (filename) {
                if (filename !== false) {
                  const oldPath = `${path}/${oldFileName}`
                  const newPath = `${path}/${filename}`
                  fileManager.mv(
                    oldPath,
                    newPath,
                    function () {
                      swal('重命名成功', '文件重命名成功!', 'success')
                      self.$dispatch('cmd-file-rename', oldPath, newPath)
                      self.$dispatch('cmd-refresh-tree')
                    },
                    function () {
                      swal.showInputError('重命名文件失败.')
                    }
                  )
                }
              })
              break
            }
          case 'del':
            {
              const paths = evt.jstree.get_path(evt.node)
              const path = paths.join('/')
              swal({
                title: '删除文件',
                text: `确定要删除如下文件吗(无法恢复):\n${path}`,
                type: 'warning',
                showCancelButton: true,
                closeOnConfirm: false,
                showLoaderOnConfirm: true
              }, function () {
                fileManager.rm(
                  path,
                  function () {
                    swal('删除成功', '文件删除成功!', 'success')
                    self.$dispatch('cmd-file-close', path)
                    self.$dispatch('cmd-refresh-tree')
                  },
                  function () {
                    swal('删除成功', '文件删除失败!', 'error')
                  })
              })
              break
            }
        }
      },
      itemDblClick (evt) {
        const data = evt.data
        if (data.type !== '.') {
          this.$dispatch('cmd-file-open', evt.jstree.get_path(evt.node).join('/'))
        }
      },
      getConfig () {
        const self = this
        return {
          contextmenu: {
            items (node, cb) {
              const menus = treeMenus(node)
              for (let action in menus) {
                let menu = menus[action]
                menu.action = function () {
                  self.menuClick({
                    action: action,
                    data: node.original,
                    node: node,
                    jstree: self.jstree
                  })
                }
              }
              return menus
            }
          },
          sort (a, b) {
            a = this.get_node(a)
            b = this.get_node(b)
            a = a.original.type === '.' ? '\0' + a.text : a.text
            b = b.original.type === '.' ? '\0' + b.text : b.text
            return a > b ? 1 : -1
          },
          'types': fileTypes,
          plugins: ['search', 'contextmenu', 'sort', 'types']
        }
      }
    }
  })
  const Menu = extend(BaseMenu, {
    data () {
      return {
        menus: [
          {
            name: '文件',
            items: {
              'site-create': {
                name: '新建站点'
              },
              'site-open': {
                name: '打开站点'
              }
            }
          },
          {
            name: '编辑',
            items: {
              'undo': {
                name: '撤销'
              },
              'redo': {
                name: '重做'
              },
              '-0': '-',
              'save': {
                name: '保存'
              }
            }
          },
          {
            name: 'hugo',
            items: {
              'hugo-start': {
                name: '启动'
              },
              'hugo-restart': {
                name: '重启'
              },
              'hugo-stop': {
                name: '停止'
              }
            }
          },
          {
            name: '帮助',
            items: {
              'about': {
                name: '关于'
              }
            }
          }
        ]
      }
    }
  })

  export default {
//    store,
//    vuex: {
//      getters: {
//      },
//      actions: {
//      }
//    },
    data () {
      return {
        rightView: '',
        sitePath: '.'
      }
    },
    methods: {
      refreshTree (sitePath, done, error) {
        const self = this
        sitePath = sitePath || this.sitePath
        fileManager.ls(sitePath, function (data) {
          self.sitePath = data[0].text
          self.$refs.treeView.refresh(data)
          if (_.isFunction(done)) {
            done()
          }
        }, error)
      },
      getEditor () {
        return this.$refs.rightView
      }
    },
    ready () {
      this.refreshTree()
      const self = this

      rpc.connect('hugo', {
        log (rpc, data) {
          self.$broadcast('console-hugo', data)
        }
      }).then(function (hugo) {
        let handlers = {
          'cmd-file-open' (path) {
            self.rightView = 'EditorManager'
            self.$nextTick(function () {
              self.getEditor().open(path)
            })
          },
          'cmd-file-close' (path) {
            self.rightView = 'EditorManager'
            self.$nextTick(function () {
              self.getEditor().close(path)
            })
          },
          'cmd-file-rename' (oldPath, newPath) {
            self.rightView = 'EditorManager'
            self.$nextTick(function () {
              self.getEditor().rename(oldPath, newPath)
            })
          },
          'cmd-file-save' () {
            self.getEditor().save()
          },
          'cmd-refresh-tree' () {
            self.refreshTree()
          },
          'cmd-site-create' () {
            swal({
              title: '新建站点',
              text: '请输入站点路径:',
              type: 'input',
              inputType: 'text',
              inputValue: self.sitePath,
              showCancelButton: true,
              closeOnConfirm: true
            }, function (sitePath) {
              if (sitePath !== false) {
                hugo.create({
                  path: sitePath
                }, function () {
                  self.refreshTree(sitePath)
                  hugo.restart({
                    path: sitePath
                  })
                })
              }
            })
          },
          'cmd-site-open' () {
            swal({
              title: '打开站点',
              text: '请输入站点路径:',
              type: 'input',
              inputType: 'text',
              inputValue: self.sitePath,
              showCancelButton: true,
              closeOnConfirm: false,
              showLoaderOnConfirm: true
            }, function (sitePath) {
              hugo.stop()
              if (sitePath !== false) {
                self.refreshTree(sitePath, function () {
                  swal('打开成功', '站点打开成功!', 'success')
                }, function () {
                  swal('打开失败', '站点打开失败!', 'error')
                })
              }
            })
          },
          'cmd-hugo-start' () {
            hugo.start({
              path: self.sitePath,
              theme: 'hugo-vaniship-theme'
            })
          },
          'cmd-hugo-restart' () {
            hugo.restart()
          },
          'cmd-hugo-stop' () {
            hugo.stop()
          },
          'cmd-undo' () {
            self.getEditor().undo()
          },
          'cmd-redo' () {
            self.getEditor().redo()
          },
          'cmd-save' () {
            self.getEditor().save()
          },
          'cmd-about' () {
            swal('Hugo Helper', 'MIT License\nv0.0.3')
          }
        }
        for (let key in handlers) {
          self.$on(key, handlers[key])
        }
      })
    },
    components: {
      XFrame,
      Menu,
      Tree,
      EditorManager,
      Console,
      State
    }
  }
</script>

<style>
  html, body {
    padding: 0;
    margin: 0;
    height: 100%;
  }

  body {
    padding: 4px;
    background-color: #F6F6F6;
    box-sizing: border-box;
  }

  textarea {
    width: 100%;
    resize: none;
    padding: 0;
    margin: 0;
    border: grey;
  }

  .cm-matchhighlight {
    background-color: lightgreen
  }

  .CodeMirror-selection-highlight-scrollbar {
    background-color: green
  }
</style>

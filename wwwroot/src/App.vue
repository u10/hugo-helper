<template>
  <x-frame :gutter-size="5">
    <menu slot="menu"></menu>
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
  import {hugo} from './lib/ws'
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
        label: '查看',
        _disabled: data.type === '.'
      },
      add: {
        label: '新建'
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
          case 'add':
            swal({
              title: '新建文件',
              text: '请输入文件名:',
              type: 'input',
              inputType: 'text',
              showCancelButton: true,
              closeOnConfirm: false
            }, function (filename) {
              if (filename !== false) {
                const paths = evt.jstree.get_path(evt.node)
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
                closeOnConfirm: false
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
                closeOnConfirm: false
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
              create_site: {
                name: '新建站点'
              },
              open_site: {
                name: '打开站点'
              }
            }
          },
          {
            name: '编辑',
            items: {
              undo: {
                name: '撤销'
              },
              redo: {
                name: '重做'
              },
              '-0': '-',
              save: {
                name: '保存'
              }
            }
          },
          {
            name: 'hugo',
            items: {
              start: {
                name: '启动'
              },
              restart: {
                name: '重启'
              },
              stop: {
                name: '停止'
              }
            }
          },
          {
            name: '帮助',
            items: {
              about: {
                name: '关于'
              }
            }
          }
        ]
      }
    },
    methods: {
      menuClick (key) {
        switch (key) {
          case 'start':
            hugo.start({
              theme: 'hugo-vaniship-theme'
            })
            break
          case 'restart':
            hugo.restart()
            break
          case 'stop':
            hugo.stop()
            break
          case 'undo':
            this.getEditor().undo()
            break
          case 'redo':
            this.getEditor().redo()
            break
          case 'save':
            this.getEditor().save()
            break
          case 'about':
            swal('Hugo Helper', 'MIT License\nv0.0.1')
            break
        }
        console.log(key)
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
        projectPath: '.'
      }
    },
    methods: {
      refreshTree (projectPath) {
        if (projectPath && (projectPath !== this.projectPath)) {
          this.projectPath = projectPath
        }
        const self = this
        fileManager.ls(this.projectPath, function (data) {
          self.$refs.treeView.refresh(data)
        })
      },
      getEditor () {
        return this.$refs.rightView
      }
    },
    ready () {
      this.refreshTree()
      const self = this
      hugo.addConsoleListener(function (data) {
        self.$broadcast('console-hugo', data)
      })

      this.$on('cmd-file-open', function (path) {
        self.rightView = 'EditorManager'
        this.$nextTick(function () {
          self.getEditor().open(path)
        })
      })
      this.$on('cmd-file-close', function (path) {
        self.rightView = 'EditorManager'
        this.$nextTick(function () {
          self.getEditor().close(path)
        })
      })
      this.$on('cmd-file-rename', function (oldPath, newPath) {
        self.rightView = 'EditorManager'
        this.$nextTick(function () {
          self.getEditor().rename(oldPath, newPath)
        })
      })
      this.$on('cmd-file-save', function () {
        self.getEditor().save()
      })
      this.$on('cmd-refresh-tree', function () {
        self.refreshTree()
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

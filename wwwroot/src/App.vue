<template>
  <x-frame :content="currentView" :gutter-size="5">
    <menu slot="menu"
          :model="mainMenu"
          @menu-click="mainMenuClick"></menu>
    <tree class="border"
          slot="left"
          :menu="treeMenu.data"
          :data="window.explorer.data"
          @menu-click="treeMenuClick"
          @item-dblclick="treeItemDblClick"></tree>
    <component slot="right"
               :is="rightView"
               v-ref:right-view
               :content-provider="contentProvider"
               @save="onSave"></component>
    <console slot="bottom" :id="'hugo'"></console>
    <state slot="state"></state>
  </x-frame>
</template>

<script>
  import {hugo} from './lib/ws'
  import store from './vuex/store'
  import {window} from './vuex/getters'
  import {setExplorerData} from './vuex/actions'
  import $ from 'jquery'
  import XFrame from './components/XFrame'
  import Editor from './components/Editor'
  import Menu from './components/Menu'
  import Console from './components/Console'
  import State from './components/State'
  import Tree from './components/Tree'
  import {Base64} from 'js-base64'
  import swal from './lib/vue-sweetalert'
  export default {
    store,
    vuex: {
      getters: {
        window
      },
      actions: {
        setExplorerData
      }
    },
    data () {
      return {
        rightView: '',
        projectPath: '.',
        mainMenu: [
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
        ],
        treeMenu: {
          data (node) {
            const data = node.original
            return {
              open: {
                label: '查看',
                _disabled: data.type === '+'
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
        }
      }
    },
    methods: {
      contentProvider (path, done) {
        $.ajax({
          url: '/cli/file/' + encodeURIComponent('get -p ' + path),
          success (ret) {
            done(ret.data)
          }
        })
      },
      onSave (data) {
        $.ajax({
          url: '/cli/file/' + encodeURIComponent(`set -p ${data.path} -d ${Base64.encode(data.draft)}`),
          complete (xhr, status) {
            if (status === 'success') {
              data.content = data.draft
              data.draft = null
              console.log('save done!')
            } else {
              console.log('save failed')
            }
          }
        })
      },
      treeMenuClick (evt) {
        const self = this
        switch (evt.action) {
          case 'open':
            this.openFile(evt.jstree.get_path(evt.node).join('/'))
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
                const path = paths.join('/')
                $.ajax({
                  url: '/cli/file/' + encodeURIComponent(`add -p ${path}/${filename}`)
                }).done(function (data) {
                  swal('创建成功', '文件创建成功!', 'success')
                  self.openFile(`${path}/${filename}`)
                  self.refreshTree()
                }).error(function (data) {
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
                  $.ajax({
                    url: '/cli/file/' + encodeURIComponent(`rename -p ${path}/${oldFileName} -d ${path}/${filename}`)
                  }).done(function (data) {
                    swal('重命名成功', '文件重命名成功!', 'success')
                    self.renameFile(`${path}/${oldFileName}`, `${path}/${filename}`)
                    self.refreshTree()
                  }).error(function (data) {
                    swal.showInputError('重命名文件失败.')
                  })
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
                $.ajax({
                  url: '/cli/file/' + encodeURIComponent(`del -p ${path}`)
                }).done(function (data) {
                  swal('删除成功', '文件删除成功!', 'success')
                  self.closeFile(path)
                  self.refreshTree()
                }).error(function (data) {
                  swal('删除成功', '文件删除失败!', 'error')
                })
              })
              break
            }
        }
      },
      mainMenuClick (key) {
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
            this.$broadcast('cmd-undo')
            break
          case 'redo':
            this.$broadcast('cmd-redo')
            break
          case 'save':
            this.$broadcast('cmd-save')
            break
          case 'about':
            swal('Hugo Helper', 'MIT License\nv0.0.1')
            break
        }
        console.log(key)
      },
      treeItemDblClick (evt) {
        const data = evt.data
        if (data.type !== '+') {
          this.openFile(evt.jstree.get_path(evt.node).join('/'))
        }
      },
      refreshTree (projectPath) {
        if (projectPath && (projectPath !== this.projectPath)) {
          this.projectPath = projectPath
        }
        const self = this
        $.ajax({
          url: '/cli/dir/' + encodeURIComponent(`list -p ${this.projectPath} -d 32`),
          success (data) {
            self.setExplorerData(data.data)
          }
        })
      },
      openFile (path) {
        this.rightView = 'Editor'
        const self = this
        this.$nextTick(function () {
          self.$refs.rightView.open(path)
        })
      },
      renameFile (oldPath, newPath) {
        this.rightView = 'Editor'
        const self = this
        this.$nextTick(function () {
          self.$refs.rightView.rename(oldPath, newPath)
        })
      },
      closeFile (path) {
        this.rightView = 'Editor'
        const self = this
        this.$nextTick(function () {
          self.$refs.rightView.close(path)
        })
      }
    },
    watch: {},
    ready () {
      this.refreshTree()
      const self = this
      hugo.addConsoleListener(function (data) {
        self.$broadcast('console-hugo', data)
      })
    },
    components: {
      XFrame,
      Menu,
      Editor,
      Console,
      State,
      Tree
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
</style>

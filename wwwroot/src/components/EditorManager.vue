<template>
  <div class="flex v-flex fill">
    <div handle=".drag-handle" style="overflow-x: scroll">
      <div v-for="file in files" class="drag-handle">
        <div @click="switchTo($index)" :class="(selected===$index)?'tab tab-selected':'tab'">
          {{file.path | filename}}
          <span v-if="file.draft !== null && (file.draft !== file.content)">*</span>
          <span class="btn-close" @click="close($index)">X</span>
        </div>
      </div>
    </div>
    <div class="flex-box">
      <div class="flex-ctrl margin-s">
        <div class="flex-content">
          <component :is="editor || 'Default'" :data="files[selected]" v-ref:editor></component>
        </div>
      </div>
      <div v-if="previewer && files[selected] && files[selected].showPreviewer" class="flex-ctrl margin-s">
        <div class="flex-content">
          <component :is="previewer" :data="files[selected]" v-ref:previewer></component>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import _ from 'lodash'

  function getIndex (files, id) {
    let index
    if (_.isNumber(id)) {
      index = id
    } else if (_.isString(id)) {
      index = _.findIndex(files, function (item) {
        return item.path === id
      })
    } else if (_.isObject(id)) {
      index = _.indexOf(files, id)
    }
    return index
  }

  function getFileName (path) {
    const index = Math.max(path.lastIndexOf('/'), path.lastIndexOf('\\'))
    if (index === -1) {
      return path
    } else {
      return path.substr(index + 1)
    }
  }

  function defaultTemplate (msg) {
    return `<div style="height: 100%; display: flex; align-items: center"><p style="width: 100%;text-align: center;color: grey">${msg}</p></div>`
  }

  function safeCall () {
    let [method, obj, ...args] = arguments
    if (obj && _.isString(method)) {
      method = obj[method]
    }
    if (_.isFunction(method)) {
      method.apply(obj, args)
    }
  }

  export default {
    data () {
      return {
        files: [],
        selected: -1
      }
    },
    ready () {
      const self = this
      this.$on('save', function (data) {
        safeCall('doSave', self, data)
      })
      this.$on('viewPointChanged', function (info) {
        if (self.$refs.previewer) {
          safeCall('syncViewPoint', self.$refs.previewer, info)
        }
      })
    },
    computed: {
      editor () {
        if (this.files.length === 0) {
          return 'Empty'
        } else {
          return this.getEditorComponent(this.files[this.selected].path)
        }
      },
      previewer () {
        if (this.files.length === 0) {
          return null
        } else {
          return this.getPreviewerComponent(this.files[this.selected].path)
        }
      }
    },
    methods: {
      getEditorComponent () {},
      getPreviewerComponent () {},
      switchTo (id) {
        const index = getIndex(this.files, id)
        if (index === -1) {
          return false
        }
        this.selected = index
        this.focus()
        return true
      },
      undo () {
        safeCall('undo', this.$refs.editor)
      },
      redo () {
        safeCall('redo', this.$refs.editor)
      },
      open (path) {
        if (this.switchTo(path)) {
          return
        }
        const self = this
        this.getContent(path, function (content) {
          self.files.push({
            path: path,
            content: content,
            draft: null,
            showPreviewer: true
          })
          self.selected = self.files.length - 1
          self.focus()
        })
      },
      rename (oldPath, newPath) {
        const index = getIndex(this.files, oldPath)
        if (index >= 0) {
          this.files[index].path = newPath
        }
      },
      close (id) {
        const index = getIndex(this.files, id || this.selected)
        if (index >= 0) {
          this.files.splice(index, 1)
          if (this.selected === this.files.length) {
            this.selected = this.files.length - 1
          }
          this.focus()
        }
      },
      save () {
        safeCall('save', this.$refs.editor)
      },
      focus () {
        safeCall('focus', this.$refs.editor)
      }
    },
    components: {
      Default: {
        template: defaultTemplate('Unknown File.')
      },
      Empty: {
        template: defaultTemplate('No File Opened.')
      }
    },
    filters: {
      filename (path) {
        return getFileName(path)
      }
    }
  }
</script>

<style>
  .drag-handle {
    display: inline-block;
    text-align: center;
    margin: 0 1px;
  }

  .tab {
    border-top: 1px solid;
    border-left: 1px solid;
    border-right: 1px solid;
    border-radius: 5px 5px 0 0;
    border-color: lightgray;
    background: #F6F6F6;
    padding: 5px;
    font-size: 10pt;
    cursor: pointer;
  }

  .tab:hover {
    background: lightgray;
  }

  .btn-close:hover {
    color: red;
  }

  .tab-selected {
    background: white;
  }
</style>

<template>
  <div class="flex v-flex fill">
    <div handle=".drag-handle" style="overflow-x: scroll">
      <div v-for="editor in editors" class="drag-handle">
        <div @click="switchTo($index)" :class="(selected===$index)?'tab tab-selected':'tab'">
          {{editor.path | filename}}
          <span v-if="editor.draft !== null && (editor.draft !== editor.content)">*</span>
          <span class="btn-close" @click="close($index)">X</span>
        </div>
      </div>
    </div>
    <div class="flex-box">
      <div class="flex-ctrl margin-s">
        <div class="flex-content">
          <component :is="currentView || 'Default'" :data="editors[selected]" v-ref:content></component>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import _ from 'lodash'

  function getIndex (editors, id) {
    let index
    if (_.isNumber(id)) {
      index = id
    } else if (_.isString(id)) {
      index = _.findIndex(editors, function (item) {
        return item.path === id
      })
    } else if (_.isObject(id)) {
      index = _.indexOf(editors, id)
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
        editors: [],
        selected: -1
      }
    },
    ready () {
      const self = this
      this.$on('save', function (data) {
        safeCall('doSave', self, data)
      })
    },
    computed: {
      currentView () {
        if (this.editors.length === 0) {
          return 'Empty'
        } else {
          return this.getComponentType(this.editors[this.selected].path)
        }
      }
    },
    methods: {
      getComponentType () {},
      switchTo (id) {
        const index = getIndex(this.editors, id)
        if (index === -1) {
          return false
        }
        this.selected = index
        this.focus()
        return true
      },
      undo () {
        safeCall('undo', this.$refs.content)
      },
      redo () {
        safeCall('redo', this.$refs.content)
      },
      open (path) {
        if (this.switchTo(path)) {
          return
        }
        const self = this
        this.getContent(path, function (content) {
          self.editors.push({
            path: path,
            content: content,
            draft: null
          })
          self.selected = self.editors.length - 1
          self.focus()
        })
      },
      rename (oldPath, newPath) {
        const index = getIndex(this.editors, oldPath)
        if (index >= 0) {
          this.editors[index].path = newPath
        }
      },
      close (id) {
        const index = getIndex(this.editors, id || this.selected)
        if (index >= 0) {
          this.editors.splice(index, 1)
          if (this.selected === this.editors.length) {
            this.selected = this.editors.length - 1
          }
          this.focus()
        }
      },
      save () {
        safeCall('save', this.$refs.content)
      },
      focus () {
        safeCall('focus', this.$refs.content)
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

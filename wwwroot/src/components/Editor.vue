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
          <component :is="currentView" :data="editors[selected]" v-ref:content></component>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import _ from 'lodash'
  import CodeMirror from './CodeMirror'
  import UnknownFile from './UnknownFile'
  import Empty from './Empty'

  function getComponentType (path) {
    if (/\.(html|xml|json|js|css|md|toml)$/i.test(path)) {
      return 'CodeMirror'
    } else {
      return 'UnknownFile'
    }
  }

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

  export default {
    props: {
      contentProvider: Function
    },
    data () {
      return {
        editors: [],
        selected: -1
      }
    },
    computed: {
      currentView () {
        if (this.editors.length === 0) {
          return 'Empty'
        } else {
          return getComponentType(this.editors[this.selected].path)
        }
      }
    },
    methods: {
      switchTo (id) {
        const index = getIndex(this.editors, id)
        if (index === -1) {
          return false
        }
        this.selected = index
        this.focus()
        return true
      },
      open (path) {
        if (this.switchTo(path)) {
          return
        }
        const componentType = getComponentType(path)
        if (componentType !== 'UnknownFile') {
          const self = this
          this.contentProvider(path, function (content) {
            self.editors.push({
              path: path,
              content: content,
              draft: null
            })
            self.selected = self.editors.length - 1
            self.focus()
          })
        } else {
          this.editors.push({
            path: path
          })
          this.selected = this.editors.length - 1
          this.focus()
        }
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
      focus () {
        this.$refs.content.focus()
      }
    },
    components: {
      CodeMirror,
      UnknownFile,
      Empty
    },
    filters: {
      filename (path) {
        return getFileName(path)
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
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

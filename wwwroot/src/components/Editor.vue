<template>
  <div class="flex v-flex fill">
    <div handle=".drag-handle" style="overflow-x: scroll">
      <div v-for="item in editor.data" class="drag-handle">
        <div @click="switchTo($index)" :class="(editor.selected[0]===$index)?'tab tab-selected':'tab'">
          {{item.title}} <span v-if="isChange(item)">*</span> <span class="btn-close" @click="close($index)">X</span>
        </div>
      </div>
    </div>
    <div class="flex-box">
      <div class="flex-ctrl margin-s">
        <div class="flex-content">
          <component :is="currentView" :data="editor.data[editor.selected[0]]" v-ref:content></component>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import $ from 'jquery'
  import _ from 'lodash'
  import CodeMirror from './CodeMirror'
  import UnknownFile from './UnknownFile'
  import Empty from './Empty'
  import {editor} from '../vuex/getters'
  import {setSelectedEditor, openFile, closeFile} from '../vuex/actions'

  function getComponentType (data) {
    if (data) {
      const title = data.title
      if (/\.(html|htm|json|js|css|md|toml)$/i.test(title)) {
        return 'CodeMirror'
      } else {
        return 'UnknownFile'
      }
    } else {
      return 'Empty'
    }
  }

  export default {
    route: {
      data () {
        if (this.$route.query.path) {
          this.open({
            title: this.$route.query.title,
            path: this.$route.query.path
          })
        }
        this.$router.replace({name: 'editor'})
      }
    },
    vuex: {
      getters: {
        editor
      },
      actions: {
        setSelectedEditor,
        openFile,
        closeFile
      }
    },
    ready () {
      const self = this
      this.$on('cmd-close', function (path) {
        self.close(path)
      })
    },
    computed: {
      currentView () {
        return getComponentType(this.editor.data[this.editor.selected[0]])
      }
    },
    methods: {
      isChange (data) {
        return data.draft !== null && (data.draft !== data.content)
      },
      switchTo (index) {
        this.setSelectedEditor(index)
        this.focus()
      },
      close (index) {
        if (_.isUndefined(index)) {
          index = this.editor.data[this.editor.selected[0]]
        } else if (_.isString(index)) {
          index = _.findIndex(this.editor.data, function (item) {
            return item.path === index
          })
        }
        if (index >= 0) {
          this.closeFile(index)
          this.focus()
        }
      },
      open (file) {
        const componentType = getComponentType(file)
        if (componentType !== 'UnknownFile') {
          const self = this
          $.ajax({
            url: '/cli/file/' + encodeURIComponent('get -p ' + file.path),
            success (ret) {
              self.openFile({
                title: file.title,
                path: file.path,
                content: ret.data,
                draft: null
              })
            }
          })
        } else {
          this.openFile({
            title: file.title,
            path: file.path
          })
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

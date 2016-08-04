<template>
  <div style="height:100%;" @keydown.s="onSave">
    <textarea v-el:codemirror></textarea>
  </div>
</template>

<script>
  import _ from 'lodash'
  import CodeMirror from 'codemirror'
  import '../../../node_modules/codemirror/addon/search/search'
  import '../../../node_modules/codemirror/addon/search/match-highlighter'
  import '../../../node_modules/codemirror/addon/dialog/dialog.css'
  import '../../../node_modules/codemirror/mode/meta'
  import '../../../node_modules/codemirror/mode/htmlmixed/htmlmixed'
  import '../../../node_modules/codemirror/mode/gfm/gfm'
  import '../../../node_modules/codemirror/mode/toml/toml'

  export default {
    ready () {
      const self = this
      const codemirror = this.codemirror = CodeMirror.fromTextArea(this.$els.codemirror, {
        lineNumbers: true,
        extraKeys: {
          'Alt-F': 'findPersistent'
        },
        highlightSelectionMatches: {
          showToken: /\w/,
          annotateScrollbar: true
        }
      })
      codemirror.on('change', function (codemirror) {
        if (self.data) {
          self.data.draft = codemirror.getValue()
        }
      })
      codemirror.on('scroll', function (codemirror) {
        if (self.data) {
          self.data.cursor = _.extend(self.data.cursor || {}, codemirror.getScrollInfo())
        }
      })
      codemirror.on('blur', function (codemirror) {
        if (self.data && codemirror.getCursor() !== 0) {
          self.data.cursor = _.extend(self.data.cursor || {}, codemirror.getCursor())
          self.data.history = codemirror.getHistory()
        }
      })
      this.$on('cmd-undo', function () {
        codemirror.undo()
      })
      this.$on('cmd-redo', function () {
        codemirror.redo()
      })
      this.$on('cmd-save', function () {
        self.save()
      })
      this.reload()
      this.setMode()
    },
    activate (done) {
      done()
      this.focus()
    },
    methods: {
      reload () {
        const data = this.data
        const codemirror = this.codemirror
        const content = data.draft || data.content
        if (codemirror.getValue() !== content) {
          const cursor = data.cursor || {left: 0, top: 0, line: 0, ch: 0}
          codemirror.setValue(content)
          codemirror.scrollTo(cursor.left, cursor.top)
          codemirror.setCursor(cursor)
          if (data.history) {
            codemirror.setHistory(data.history)
          } else {
            codemirror.clearHistory()
          }
        }
      },
      setMode (mode) {
        mode = mode || (CodeMirror.findModeByFileName(this.data.path) || {mode: null}).mode
        console.log(mode)
        this.codemirror.setOption('mode', mode)
      },
      focus () {
        if (this.codemirror) {
          this.codemirror.focus()
        }
      },
      save () {
        if (this.data && (this.data.content !== this.data.draft)) {
          this.$dispatch('save', this.data)
        }
      },
      onSave (evt) {
        if (evt.ctrlKey || evt.metaKey) {
          evt.preventDefault()
          evt.stopPropagation()
          this.save()
        }
      }
    },
    props: {
      data: Object
    },
    watch: {
      'data.path' () {
        this.setMode()
      },
      'data.content' () {
        this.reload()
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
  @import '../../../node_modules/codemirror/lib/codemirror.css';

  .CodeMirror {
    border: 1px solid #eee;
    height: 100%;
    z-index: 0;
  }

  .cm-matchhighlight {
    background-color: lightgreen
  }

  .CodeMirror-selection-highlight-scrollbar {
    background-color: green
  }
</style>

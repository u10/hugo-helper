<template>
  <div style="height:100%;" @keydown.s="onSave">
    <textarea v-el:codemirror></textarea>
  </div>
</template>

<script>
  import _ from 'lodash'
  import CodeMirror from 'codemirror'

  const defaultConfig = {
    lineNumbers: true
  }

  export default {
    ready () {
      const self = this
      const codemirror = this.codemirror = CodeMirror.fromTextArea(
        this.$els.codemirror,
        _.defaults(this.getConfig(), defaultConfig)
      )
      codemirror.on('change', function (cm) {
        if (self.data) {
          self.data.draft = cm.getValue()
        }
      })
      codemirror.on('scroll', function (cm) {
        if (self.data) {
          self.data.cursor = _.extend(self.data.cursor || {}, cm.getScrollInfo())
        }
      })
      codemirror.on('blur', function (cm) {
        if (self.data && cm.getCursor() !== 0) {
          self.data.cursor = _.extend(self.data.cursor || {}, cm.getCursor())
          self.data.history = cm.getHistory()
        }
      })
      this.reload()
      this.setMode()
    },
    activate (done) {
      done()
      this.focus()
    },
    methods: {
      undo () {
        this.codemirror.undo()
      },
      redo () {
        this.codemirror.redo()
      },
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
      getMode (path) {
        let mode = null
        if (_.isFunction(CodeMirror.findModeByFileName)) {
          mode = (CodeMirror.findModeByFileName(path) || {mode: null}).mode
        }
        return mode
      },
      setMode (mode) {
        this.codemirror.setOption('mode', mode || this.getMode(this.data.path))
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

<style>
  @import '../../../node_modules/codemirror/lib/codemirror.css';

  .CodeMirror {
    border: 1px solid #eee;
    height: 100%;
    z-index: 0;
  }
</style>

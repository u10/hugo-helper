<template>
  <div v-html="data.draft || data.content | marked" style="height: 100%;overflow: auto;background: white"></div>
</template>

<script>
  import _ from 'lodash'
  import $ from 'jquery'
  import marked from 'marked'

  const selector = 'p, h1, h2, h3, h4, h5, h6, li, pre, blockquote, hr, table'
  const metaDataPattern = /\+{3,}\s*\n(.*\n)*\+{3,}\s*\n/

  function trimMetaData (text) {
    if (_.isEmpty(text)) {
      return ''
    } else {
      return text.replace(metaDataPattern, '')
    }
  }

  function getCursorLineNumber (codeMirror) {
    let lineNumber = codeMirror.getCursor().line
    let range = codeMirror.getRange({line: 0, ch: 0}, {line: lineNumber, ch: null})
    var doc = $(`<div>${marked(trimMetaData(range))}</div>`)
    let totalLines = doc.find(selector)
    return totalLines.length - 1
  }

  function getScorllLineNumber (codeMirror) {
    let scrollInfo = codeMirror.getScrollInfo()
    let lineNumber = codeMirror.lineAtHeight(scrollInfo.top, 'local')
    let range = codeMirror.getRange({line: 0, ch: 0}, {line: lineNumber, ch: null})
    let content = trimMetaData(range)
    if (content === range && metaDataPattern.test(codeMirror.getValue())) {
      return 0
    } else {
      var doc = $(`<div>${marked(content)}</div>`)
      let totalLines = doc.find(selector)
      return totalLines.length
    }
  }

  const syncPreviewScroll = _.debounce(function ($el, lineNumber) {
    let elems = $el.find(selector)
    if (elems.length > 0 && elems[lineNumber]) {
      $el.stop().animate({ scrollTop: elems[lineNumber].offsetTop - $el[0].offsetTop, queue: false })
    }
  }, 200)

  export default {
    props: {
      data: Object
    },
    methods: {
      syncViewPoint (info) {
        let lineNumber
        if (info.trigger === 'cursor') {
          lineNumber = getCursorLineNumber(info.codemirror)
        } else {
          lineNumber = getScorllLineNumber(info.codemirror)
        }
        syncPreviewScroll($(this.$el), lineNumber)
      }
    },
    filters: {
      marked (content) {
        return marked(trimMetaData(content))
      }
    }
  }
</script>

<style>

</style>

<template>
  <div class="flex v-flex fill">
    <div class="flex">
      <div style="padding: 2px">搜索</div>
      <input style="-webkit-flex: 1;min-width: 30px" v-model="keyword"/>
    </div>
    <div class="flex-box">
      <div class="flex-ctrl margin-s">
        <div class="flex-content">
          <div v-el:jstree></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import _ from 'lodash'
  import $ from 'jquery'
  import 'jstree'
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
    props: {
      data: Array,
      menu: Function
    },
    data () {
      return {
        keyword: ''
      }
    },
    ready () {
      const self = this
      const jstree = this.jstree = $(this.$els.jstree)
        .on('activate_node.jstree', function (event, obj) {
          const node = obj.node
          safeCall('itemClick', self, {
            srcEvt: event,
            data: node.original,
            node,
            jstree
          })
        })
        .on('select_node.jstree', function (event, obj) {
          const node = obj.node
          safeCall('itemSelect', self, {
            srcEvt: event,
            data: node.original,
            node,
            jstree
          })
        })
        .on('dblclick.jstree', function (event) {
          const node = self.jstree.get_node(event.target)
          safeCall('itemDblClick', self, {
            srcEvt: event,
            data: node.original,
            node,
            jstree
          })
        })
        .jstree(_.extend({
          core: {
            data: this.data
          }
        }, this.getConfig()))
        .jstree()
    },
    methods: {
      getConfig () {},
      refresh (data) {
        this.data = data
      }
    },
    watch: {
      keyword (val) {
        if (_.isFunction(this.jstree.search)) {
          this.jstree.search(val)
        }
      },
      data (val) {
        this.jstree.settings.core.data = val
        this.jstree.refresh(true)
      }
    }
  }
</script>

<style>
  @import "../../../node_modules/jstree/dist/themes/default/style.css";
</style>

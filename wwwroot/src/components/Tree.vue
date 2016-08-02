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
  import $ from 'jquery'
  import 'jstree'
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
          self.$dispatch('item-click', {
            srcEvt: event,
            data: node.original,
            node,
            jstree
          })
        })
        .on('select_node.jstree', function (event, obj) {
          const node = obj.node
          self.$dispatch('item-select', {
            srcEvt: event,
            data: node.original,
            node,
            jstree
          })
        })
        .on('dblclick.jstree', function (event) {
          const node = self.jstree.get_node(event.target)
          self.$dispatch('item-dblclick', {
            srcEvt: event,
            data: node.original,
            node,
            jstree
          })
        })
        .jstree({
          core: {
            data: this.data
          },
          contextmenu: {
            items (node, cb) {
              const menus = self.menu(node)
              for (let action in menus) {
                let menu = menus[action]
                menu.action = function () {
                  self.$dispatch('menu-click', {
                    action: action,
                    data: node.original,
                    node: node,
                    jstree
                  })
                }
              }
              return menus
            }
          },
          plugins: ['search', 'contextmenu']
        })
        .jstree()
    },
    watch: {
      keyword (val) {
        this.jstree.search(val)
      },
      data (val) {
        this.jstree.settings.core.data = val
        this.jstree.refresh(true)
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
  @import "../../../node_modules/jstree/dist/themes/default/style.css";
</style>

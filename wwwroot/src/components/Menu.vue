<template>
  <div class="menu-container">
    <div v-for="menu in model" class="top-menu-item" style="display: inline-block" :data-index="$index">{{menu.name}}</div>
  </div>
</template>

<script>
  import $ from 'jquery'
  import 'jquery-contextmenu'

  export default {
    props: {
      model: Array
    },
    ready () {
      const self = this
      $.contextMenu({
        selector: '.top-menu-item',
        trigger: 'left',
        appendTo: this.$el,
        position (opt, x, y) {
          const $el = opt.$trigger
          opt.$menu.css({top: $el.offset().top + $el.height(), left: $el.offset().left - 5})
        },
        build ($trigger, e) {
          return {
            callback (key, opt) {
              self.$dispatch('menu-click', key, opt)
            },
            items: self.model[$trigger.data('index')].items
          }
        }
      })
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
  @import "../../../node_modules/jquery-contextmenu/dist/jquery.contextMenu.css";

  .top-menu-item {
    display: inline-block;
    padding: 2px 5px;
    cursor: pointer;
  }

  .top-menu-item:hover {
    background: #2980b9;
    color: white;
  }

  .context-menu-active {
    background: #2980b9;
    color: white;
  }

  .menu-container {
    width: 100%;
    border-bottom: 1px lightgray solid;
    padding-bottom: 2px;
    margin-bottom: 2px;
  }
</style>

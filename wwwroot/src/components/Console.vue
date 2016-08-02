<template>
  <div class="flex v-flex fill">
    <div class="flex-box">
      <div class="flex-ctrl" style="border: 1px lightgray solid;">
        <div v-el:container class="flex-content console">
          <pre v-el:content></pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import $ from 'jquery'
  export default {
    data () {
      return {
        cmd: ''
      }
    },
    props: {
      id: String
    },
    ready () {
      const $content = $(this.$els.content)
      const $container = $(this.$els.container)
      this.$on(`console-${this.id}`, function (data) {
        $content.append(data)
        $container.scrollTop(Number.MAX_VALUE)
      })
    },
    methods: {
      sendCommand () {
        this.$dispatch('exec-command', {
          id: this.id,
          cmd: this.cmd
        })
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  pre {
    font-size: 8pt;
    color: white;
  }

  .console {
    background: black;
    color: white;
  }

  .commander {
    width: 98%;
    border: none;
    -webkit-touch-callout: none;
    -webkit-appearance: none;
    -webkit-user-select: none;
    user-select: none;
    -webkit-tap-highlight-color:rgba(255, 255, 255, 0);
  }
</style>

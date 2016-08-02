<template>
  <div class="flex v-flex fill">
    <slot name="menu"></slot>
    <div class="flex-box">
      <div class="flex-ctrl">
        <div class="flex-content">
          <div v-el:top class="top split">
            <div v-el:top-left class="split split-horizontal">
              <div class="flex-box v-flex">
                <div class="flex-ctrl margin-s">
                  <div class="flex-content">
                    <slot name="left"></slot>
                  </div>
                </div>
              </div>
            </div>
            <div v-el:top-right class="split split-horizontal">
              <div class="flex-box v-flex">
                <div class="flex-ctrl">
                  <div class="flex-content">
                    <slot name="right"></slot>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div v-el:bottom class="split">
            <div class="flex v-flex fill">
              <div class="flex-box">
                <div class="flex-ctrl margin-s">
                  <div class="flex-content">
                    <slot name="bottom"></slot>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <slot name="state"></slot>
  </div>
</template>

<script>
  import Split from 'split.js'
  export default {
    props: {
      gutterSize: Number
    },
    components: {

    },
    ready () {
      Split([this.$els.top, this.$els.bottom], {
        sizes: [80, 20],
        direction: 'vertical',
        gutterSize: this.gutterSize,
        cursor: 'row-resize'
      })

      Split([this.$els.topLeft, this.$els.topRight], {
        sizes: [25, 75],
        gutterSize: this.gutterSize,
        cursor: 'col-resize'
      })
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
  .split {
    -webkit-box-sizing: border-box;
    -moz-box-sizing: border-box;
    box-sizing: border-box;

    overflow-y: auto;
    overflow-x: hidden;
  }

  .gutter {
    background-color: transparent;

    background-repeat: no-repeat;
    background-position: 50%;
  }

  .gutter.gutter-horizontal {
    cursor: col-resize;
    background-image: url('../assets/img/grips/vertical.png');
  }

  .gutter.gutter-vertical {
    cursor: row-resize;
    background-image: url('../assets/img/grips/horizontal.png');
  }

  .split.split-horizontal, .gutter.gutter-horizontal {
    height: 100%;
    float: left;
  }

  .flex {
    display: -webkit-flex;
  }

  .v-flex {
    flex-direction: column;
  }

  .flex-box {
    display: -webkit-flex;
    height: 100%;
  }

  .flex-box .flex-ctrl {
    -webkit-flex: 1;
    position: relative;
  }

  .flex-ctrl .flex-content {
    overflow: auto;
    width: 100%;
    height: 100%;
    position: absolute;
  }

  .margin-s {
    margin: 3px;
  }

  .fill {
    width: 100%;
    height: 100%;
  }
</style>

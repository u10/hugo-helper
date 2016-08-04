import swal from 'sweetalert'
import '../../../node_modules/sweetalert/dist/sweetalert.css'
import Vue from 'vue'
const swalContentSelector = '.sweet-alert p'
export default function (config, cb) {
  if (config.template || config.component) {
    let vm
    config.text = `<div style="height: ${config.contentHeight || 0}px"></div>`
    config.html = true
    const originalCallback = cb
    cb = function (result) {
      if (result !== false) {
        originalCallback(vm.$data)
        return
      }
      originalCallback(result)
      vm.destroy()
    }
    arguments[1] = cb
    swal.apply(null, arguments)
    const component = config.component
    if (component) {
      component.el = swalContentSelector
      component.replace = false
      if (config.data) {
        component.data = config.data
      }
      vm = new Vue(component)
    } else {
      vm = new Vue({
        el: swalContentSelector,
        replace: false,
        template: `${config.template}`,
        data: config.data
      })
    }
    if (config.contentHeight) {
      const el = vm.$el.children[0]
      el.style.maxHeight = config.contentHeight + 'px'
      el.style.overflow = 'auto'
    }
  } else {
    swal.apply(null, arguments)
  }
}

function icon (type) {
  return `/static/img/fileTypes/${type}.png`
}
export default {
  'default': {
    'icon': icon('unknown'),
    'valid_children': ['default', 'file']
  },
  '.': {
    'icon': '',
    'valid_children': ['default', 'file']
  },
  '.txt': {
    'icon': icon('txt')
  },
  '.log': {
    'icon': icon('txt')
  },
  '.toml': {
    'icon': icon('conf')
  },
  '.html': {
    'icon': icon('html')
  },
  '.htm': {
    'icon': icon('html')
  },
  '.json': {
    'icon': icon('json')
  },
  '.js': {
    'icon': icon('js')
  },
  '.css': {
    'icon': icon('css')
  },
  '.md': {
    'icon': icon('md')
  },
  '.zip': {
    'icon': icon('zip')
  }
}

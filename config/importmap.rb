# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "jquery", to: "jquery.js"
pin "notify", to: "notify.js"
pin "sweetalert2", to: "https://ga.jspm.io/npm:sweetalert2@11.14.4/dist/sweetalert2.all.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "echarts", to: "echarts.min.js"
pin "echarts/theme/dark", to: "echarts/theme/dark.js"

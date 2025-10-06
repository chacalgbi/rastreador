// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "jquery"
import "notify"
import "sweetalert2"

window.jQuery = window.$ = jQuery;

import "echarts"

document.addEventListener('turbo:load', function() {
  document.addEventListener('click', function(e) {
    const tooltipWrapper = e.target.closest('.tooltip-wrapper');

    if (tooltipWrapper) {
      e.preventDefault();
      e.stopPropagation();

      document.querySelectorAll('.tooltip-wrapper.active').forEach(el => {
        if (el !== tooltipWrapper) {
          el.classList.remove('active');
        }
      });

      tooltipWrapper.classList.toggle('active');
    } else {
      document.querySelectorAll('.tooltip-wrapper.active').forEach(el => {
        el.classList.remove('active');
      });
    }
  });
});

import 'package:apex_dart/src/renderer/apex_helpers.js.dart';
import 'package:apex_dart/src/renderer/apexcharts.css.dart';
import 'package:apex_dart/src/renderer/apexcharts.js.dart';

String render(options) {
  return """ 
    <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title>ApexCharts</title>
        <script>$APEX_HELPER_JS</script>
        <script>$APEX_CHARTS_JS</script>
        <style>$APEX_CHARTS_CSS</style>
      </head>
      <body>
      
        <div id="chart"></div>
        
        <div id="error_card" style="display: none; background-color: #f7f7f7; border: 1px solid #dcdcdc; border-radius: 5px; padding: 20px; margin: 10px; text-align: center;">
          <p style="color: red; font-size: 18px;">Error Encountered</p>
          <p style="color: #333; font-size: 14px;">An error occurred while rendering the chart. Please check the console for more information.</p>
          <div id="error_message" style="color: red; font-size: 14px;"></div>
        </div>

        <script>
          window.onload = function () {
            try {
              window.chart = new ApexCharts(document.querySelector("#chart"), $options);
              window.chart.render();
            }
            catch (e) {
              console.error(e);
              document.getElementById("error_card").style.display = "block";
              document.getElementById("error_message").textContent = "Error Message: " + e.message;
            }
          }
          
          
          let lastScrollTop = 0;
          let scrollTimeout;

          function debounceScrollEnd() {
            if (scrollTimeout) {
              clearTimeout(scrollTimeout);
            }
            scrollTimeout = setTimeout(() => {
              parent.postMessage({
                type: 'scroll_end',
              }, '*');
            }, 200); // Adjust debounce delay as needed
          }

          
          // Add scroll event listener and postMessage
          window.addEventListener('scroll', function() {
            const scrollPosition = window.scrollY;

            // Detect scroll direction
            const scrollDirection = scrollPosition > lastScrollTop ? 'down' : 'up';
            lastScrollTop = scrollPosition <= 0 ? 0 : scrollPosition; // For Mobile or negative scrolling
            
            parent.postMessage({
              type: 'scroll_direction',
              direction: scrollDirection,
            }, '*');
            
            parent.postMessage({
              type: 'scroll_start',
            }, '*');
            
            debounceScrollEnd();
          });

          // Detect when the user is trying to scroll beyond the top or bottom
          window.addEventListener('wheel', function(event) {
            const scrollPosition = window.scrollY;
            const maxScroll = document.documentElement.scrollHeight - window.innerHeight;

            // Check if the user is trying to scroll beyond the top
            if (event.deltaY < 0 && scrollPosition === 0) {
              parent.postMessage({
                type: 'scroll_top_attempt',
              }, '*');
            }

            // Check if the user is trying to scroll beyond the bottom
            if (event.deltaY > 0 && scrollPosition >= maxScroll) {
              parent.postMessage({
                type: 'scroll_bottom_attempt',
              }, '*');
            }
          });
               
        </script>
        
        
      </body>
    </html>
  """;
}
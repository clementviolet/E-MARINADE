sync_slider_input <- function(slider_id, input_id, session, ...){
  # Synchronize numericInput with sliderInput
  observeEvent(session$input[[slider_id]], {
    updateNumericInput(session, input_id, value = session$input[[slider_id]])
  })
  
  # Synchronize sliderInput with numericInput
  observeEvent(session$input[[input_id]], {
    updateSliderInput(session, slider_id, value = session$input[[input_id]])
  })
}
$(document).ready(function(){
  
})

function showInput(e){
  var input = $('input[name="optionsRadios"]:checked').val();
  $(".form-group").removeClass("hide");
  $("#s_id").val(input);
  $("#submit-simulation-form").removeClass("hide");
}

$("#submit-simulation-form").click(function(){
  $("#productSimulationForm").trigger("submit.rails");
})
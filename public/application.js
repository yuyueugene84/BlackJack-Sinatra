$(document).ready(function(){
  player_hits();
  player_stays();
  dealer_hits();
  turn_yellow();
  card_motion();
});

function turn_yellow() {
$('#player_color').click(function(){
  $('#player_area').css('background-color', 'yellow');
  return false; //do not continue execution of this action, run the javascript funciton specified, but not the link
});
}
  //$('#form_hit input').click(function(){
//player hit
function player_hits() {
  $(document).on('click', '#form_hit input', function() {
    $.ajax({
      type: 'POST', //this is a form
      url: '/game/player/hit'
      //data: {}
    }).done(function(msg){
      //alert(msg);
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

//player stay
function player_stays(){
  $('#form_stay input').click(function(){
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg){
      //alert(msg);
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

function dealer_hits(){
  $(document).on('click', '#form_dealer_hit input', function() {
    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
    }).done(function(msg){
      //alert(msg);
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

function card_motion(){
  $('.card_image').mouseenter(function() {
    $(this).animate({
      width: '+=10px'
    });
    $(this).toggleClass('highlighted');
  });

  $('.card_image').mouseleave(function() {
    $(this).animate({
      width: '-=10px'
    });
    $(this).toggleClass('highlighted');
  });
}
//backbone, ember, angular = frameworks built for rich interactive apps

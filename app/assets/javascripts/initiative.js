$(document).ready(function () {
  $(".share a").click(function(e) {
    e.preventDefault();
    window.open(this.href, "", "height = 500, width = 500");
  });

  $("a.colorbox").colorbox({rel:'colorbox'})
  $('.model_quarter').change(function () {
    $('.model_street').val('');
    $('.model_street').empty();
    $('.model_street').trigger('chosen:updated');
    var name = $(this).find('option:selected').text()
    $.get('/quartier/' + name + '/streets', function (data) {
      for(var i = 0; i < data.length; i++) {
        $('.model_street').append('<option value="' + [data[i].latitude, data[i].longitude].join(',') +
          '">' + data[i].name + '</option>');
      }
      $('.model_street').trigger('chosen:updated');
    });
  });

  $('.model_kommune').change(function () {
  $.get('/kommunen/' + $(this).val() + '/quartiere', function(data) {
      var $quarters = $('.model_quarter');
      $quarters.empty();
      $quarters.val('');
      for(var i = 0; i < data.length; i++) {
        $quarters.append('<option value="'+data[i].id+'">'+data[i].name+'</option>');
      }
      $quarters.val('').trigger('chosen:updated');
    });
  });
});

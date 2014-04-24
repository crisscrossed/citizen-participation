$(document).ready(function () {
  if( $('#map.start-page').length == 0) {
    return;
  }

  map = new L.Map('map').setView(new L.LatLng(50.759047 , 6.130028), 11);
  var mapboxUrl = 'http://{s}.tiles.mapbox.com/v3/okf.map-najwtvl1/{z}/{x}/{y}.png',
  mapbox = new L.TileLayer(mapboxUrl, {"attribution": "\u00a9 <a href=\"http://www.openstreetmap.org/\" target=\"_blank\">OpenStreetMap</a> contributors"});
  map.addLayer(mapbox,true);
  map.scrollWheelZoom.disable();

  // var minimap = new L.Map('minimap',{ zoomControl:false, attributionControl: false }).setView(new L.LatLng(50.709047 , 6.180028), 9);
  // minimapbox = new L.TileLayer(mapboxUrl);
  // minimap.addLayer(minimapbox,true);
  // minimap.scrollWheelZoom.disable();
  // minimap.doubleClickZoom.disable();
  // minimap.dragging.disable();

  var polygon = [[[50.57809, 6.23908], [50.5361, 6.1974], [50.54157, 6.17808], [50.55748, 6.17446], [50.59042, 6.22523], [50.57809, 6.23908]], [[50.63025, 6.27315], [50.62372, 6.18189], [50.64384, 6.1669], [50.64853, 6.2318], [50.63025, 6.27315]], [[50.52984, 6.35828], [50.53368, 6.37982], [50.49701, 6.31561], [50.4954, 6.22413], [50.53939, 6.19861], [50.56642, 6.23633], [50.62817, 6.27403], [50.64149, 6.26695], [50.64037, 6.18772], [50.66315, 6.19469], [50.66224, 6.16586], [50.72208, 6.11534], [50.71834, 6.03908], [50.74547, 6.04053], [50.76313, 6.01838], [50.7737, 6.02785], [50.79793, 5.97486], [50.81413, 6.0251], [50.84636, 6.01917], [50.85713, 6.05451], [50.84674, 6.074], [50.87239, 6.08824], [50.91024, 6.08198], [50.89817, 6.13789], [50.93656, 6.1601], [50.95009, 6.19454], [50.93495, 6.22967], [50.89758, 6.1999], [50.86342, 6.23021], [50.8846, 6.2992], [50.86759, 6.32122], [50.85415, 6.3143], [50.84394, 6.33688], [50.81714, 6.34076], [50.792, 6.29842], [50.77183, 6.31425], [50.78908, 6.35329], [50.75938, 6.36449], [50.7553, 6.34345], [50.69042, 6.3129], [50.67763, 6.28465], [50.65079, 6.3348], [50.66907, 6.37608], [50.64347, 6.38413], [50.64347, 6.40939], [50.62937, 6.40827], [50.62285, 6.3835], [50.6062, 6.38853], [50.60886, 6.41927], [50.59609, 6.39098], [50.52984, 6.35828]], [[50.66344, 6.19261], [50.64883, 6.18391], [50.6616, 6.16649], [50.66344, 6.19261]]] ;

  // for(var i = 0; i < polygon.length; i ++) {
  //   var currentPolygon = L.polygon(polygon[i], { stroke: false});
  //   currentPolygon.addTo(minimap);
  // }

  // var minimapRectangle = L.rectangle(map.getBounds(), {color: '#ff7800', weight: 1}).addTo(minimap);

  // var updateMinimap = function () {
  //   minimapRectangle.setBounds(map.getBounds());
  // };
  // map.addEventListener('move', updateMinimap);

  var markers = new L.MarkerClusterGroup();
  map.addLayer(markers);

  var refreshMarkers = function (initiatives, antraeges, constructions) {
    markers.clearLayers();

    if(initiatives)
    for(var i = 0; i < initiatives.length; i++) {
      var initiative = initiatives[i];
      if( initiative.lat.length > 0 && initiative.long.length > 0 ) {
        var initiativeIcon = L.AwesomeMarkers.icon({icon: 'initiative', color: 'red'});
        var marker = new L.marker([initiative.lat, initiative.long], { icon: initiativeIcon });
        marker.bindPopup($('.marker-popup[data-id="' + initiative.id + '"]').html());
        markers.addLayer(marker);
      }
    }

    if(antraeges)
    for(var i = 0; i < antraeges.length; i++) {
      var antraege = antraeges[i];
      var icon = L.AwesomeMarkers.icon({icon: 'info', color: 'blue'});
      var marker = L.marker([antraege.lat, antraege.long], { icon: icon });
      marker.bindPopup('<a href="/vorlagen/' + antraege.id + '">' + antraege.title + '<br>Zur Rats-info</a>');
      markers.addLayer(marker);
    }

    if(constructions)
    for(var i = 0; i < constructions.length; i++) {
      var construction = constructions[i];
      var icon = L.AwesomeMarkers.icon({icon: 'baustelle', color: 'orange'});
      var marker = L.marker([construction.lat, construction.long], { icon: icon });
      marker.bindPopup('<a href="/baustellen/' + construction.id + '">' + construction.title + '<br>' + $.datepicker.formatDate('dd.mm.yy', new Date(construction.start_date)) + ' - ' + $.datepicker.formatDate('dd.mm.yy', new Date(construction.end_date)) + '<br>Zur Baustelle</a>');
      markers.addLayer(marker);
    }
  };

  var initiatives = $('#map').data('initiatives');
  var antraeges = $('#map').data('antraeges');
  var constructions = $('#map').data('constructions');
  refreshMarkers(initiatives, antraeges, constructions);

  var kommunen = $('div[data-kommunen]').data('kommunen');
  var quartersData = $('*[data-quarters]').data('quarters');

  var zoomToKommune = function () {
    var kommune = null;
    var selected = parseInt($('#kommunen').val());
    for(var i = 0; i < kommunen.length; i++) {
      if( kommunen[i].id == selected ) {
        kommune = kommunen[i];
        break;
      }
    }

    if( kommune ) {
      $('#seitenverweis').html('  Mehr Infos zu <a href="' + '/kommunen/' + kommune.id + '">' + kommune.name + '</a>')
      map.setView(new L.LatLng(kommune.latitude, kommune.longitude), 13);
    }
    else {
      map.setView(new L.LatLng(50.759047 , 6.130028), 11);
    }
  };

  var zoomToQuarter = function () {
    var data = quartersData[$('#quarters').val()];
    var selected = $('#quarters').find(':selected');
    $('#seitenverweis').html('Mehr Infos zu <a href="' + '/quartier/' + selected.attr('value') + '">' + selected.text() + '</a>')
    var location = data.coords;
    map.setView(new L.LatLng(location[1], location[0]), 14);
  };

  $('#kommunen').change(function () {
    if( $(this).val().length == 0 ) {
      map.setView(new L.LatLng(50.775346 , 6.083887), 13);
      $('#quarters').empty().val('').trigger('chosen:updated');
      $('#streets').empty().val('').trigger('chosen:updated');
      return true;
    }
    zoomToKommune();

    $.get('/kommunen/' + $(this).val() + '/quartiere', function(data) {
      var $quarters = $('#quarters');
      $quarters.empty();
      $quarters.val('');
      $('#spinner').hide()
      for(var i = 0; i < data.length; i++) {
        $quarters.append('<option value="'+data[i].id+'">'+data[i].name+'</option>');
      }
      $quarters.val('').trigger('chosen:updated');

      updateStreets();
    });
  });

  updateStreets = function () {
    var name = $('#quarters').find('option:selected').text();
    $('#streets').empty();
    $('#streets').val('');
    if( !name || !name.length ) {
      $('#streets').trigger('chosen:updated');
    }
    else {
      $.get('/quartier/' + encodeURIComponent(name) + '/streets', function (data) {
        for(var i = 0; i < data.length; i++) {
          $('#streets').append('<option value="' + [data[i].latitude, data[i].longitude].join(',') +
            '">' + data[i].name + '</option>');
        }
        $('#streets').val('').trigger('chosen:updated');
      });
    }
  };

  $('#quarters').change(function () {
    if( $(this).val().length ) {
      zoomToQuarter();

      $('#spinner').show()
      $.get('/quartier/' + $(this).val() + '/initiatives', function(data) {
        refreshMarkers(data);
        $('#spinner').hide()
      });

      updateStreets();
    }
    else {
      zoomToKommune();
      $('#streets').empty().val('').trigger('chosen:updated');
    }
  });

  $('#streets').change(function () {
    if( $(this).val().length ) {
      var location = $(this).val().split(',');
      map.setView(new L.LatLng(location[0], location[1]), 16);
    }
    else {
      zoomToQuarter();
      $('#streets').empty().val('').trigger('chosen:updated');
    }
  });

  var path     = '/markers';
  var $form    = $('form[action="' + path + '"]');
  var params   = function(){ return $form.serialize(); };
  var $selects = $form.find('select#kommunen, select#quarters');

  $selects.change(function(){
    $.getJSON(path, params()).done(function(response){
      var initiatives   = response.initiatives;
      var antraeges     = response.antraeges;
      var constructions = response.constructions;
      var location      = response.location;
      var zoom          = response.zoom;
      refreshMarkers(initiatives, antraeges, constructions);
      map.panTo(location);
      map.setZoom(zoom);
    });
  });
});

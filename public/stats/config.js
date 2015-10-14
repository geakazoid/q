/* site name */
var site_name = 'Q2014 Stats!';

/* logo options */
var use_logo = true;
var logo = 'http://www.q2014.org/images/q2014_header.jpg';
var logo_width = 565;
var logo_height = 200;

/* navigation */
var nav = '<a href="http://www.q2014.org">Q2014 Home</a>&nbsp;&middot; \
           <a href="/">Stats Home</a>&nbsp;&middot; \
           <a href="/statindex.html">Statistics</a>&nbsp;&middot; \
           <a href="http://www.q2014.org/files/local_experienced_tournament_bracket.pdf">LX Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2014.org/files/local_novice_tournament_bracket.pdf">LN Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2014.org/files/district_experienced_tournament_bracket.pdf">DE Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2014.org/files/district_novice_tournament_bracket.pdf">DN Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2014.org/files/regionala_tournament_bracket.pdf">RA Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2014.org/files/regionalb_tournament_bracket.pdf">RB Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2014.org/files/decades_finals.pdf">Decades Bracket</a>&nbsp;&middot; \
           <a href="/tickertape.html">Rounds In Progress</a>';

/* home page options */
var load_external_site = true;
var external_site = 'http://www.trevecca.org';

/* function */
function update_from_config() {
  document.title = site_name;
  $('#header h1').html(site_name);
  $('#nav').html(nav);
  if (use_logo === true) {
    $('#logo').html('<img src="' + logo + '" width="' + logo_width + '" height="' + logo_height + '"/>');
  }
  if (load_external_site === true) {
    $('#main iframe').attr('src',external_site);
  }

  /* remove dx and lx team stats */
  $('a').each(function(k,v){
    var re = new RegExp("dx_teamstandings.html", 'ig');
    if($(this).attr("href").match(re)) {
      $(this).hide();
    }
  });
  $('a').each(function(k,v){
    var re = new RegExp("lx_teamstandings.html", 'ig');
    if($(this).attr("href").match(re)) {
      $(this).hide();
    }
  });
  update_tickertape();
}

function update_tickertape() {
  if (document.URL === "http://stats.q2014.org/tickertape.html") {
    $('tr').each(function(k,v){
      var re = new RegExp("Boone", 'ig');
      if($(this).text().match(re)) {
          $(this).find('td').css('backgroundColor', '#eeeeaa');
      }
    });
    $('tr').each(function(k,v){
      var re = new RegExp("McClurkan", 'ig');
      if($(this).text().match(re)) {
          $(this).find('td').css('backgroundColor', '#aaeeee');
      }
    });
    $('tr').each(function(k,v){
      var re = new RegExp("TCC", 'ig');
      if($(this).text().match(re)) {
          $(this).find('td').css('backgroundColor', '#eeaaee');
      }
    });

    /* hide office rows */
    $('tr').each(function(k,v){
      var re = new RegExp("Office|Test", 'ig');
      if($(this).text().match(re)) {
          $(this).hide();
      }
    });

    $("tr").each(function() {
      $(this).children('th').slice(9,11).hide();
      $(this).children('td').slice(9,11).hide();
    });

    /* add a refresh */
    setTimeout("location.reload();",300000);
  }
}

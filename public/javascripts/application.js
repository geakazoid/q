Ajax.Responders.register({
  onCreate: function(request) {
    var csrf_meta_tag = $$('meta[name=csrf-token]')[0];
    if (csrf_meta_tag) {
      var header = 'X-CSRF-Token',
          token = csrf_meta_tag.readAttribute('content');
      if (!request.options.requestHeaders) {
        request.options.requestHeaders = {};
      }
      request.options.requestHeaders[header] = token;
    }
  }
});
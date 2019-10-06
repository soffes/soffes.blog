const addLoadEvent = function(func) {
  const oldonload = window.onload;
  if (typeof window.onload !== 'function') {
    return window.onload = func;
  } else {
    return window.onload = function() {
      if (oldonload) { oldonload(); }
      return func();
    };
  }
};

addLoadEvent(function() {
  if (!document.getElementsByTagName || !String.prototype.indexOf) {
    return;
  }

  for (let anchor of document.getElementsByTagName('a')) {
    const rel = anchor.getAttribute('rel');
    const external = (rel && (rel.indexOf('external') >= 0));

    if (anchor.getAttribute('href') && (external === true)) {
      anchor.target = '_blank'
    }
  }
});

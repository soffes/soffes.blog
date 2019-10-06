addLoadEvent(function() {
  if (!document.querySelectorAll) {
    return;
  }

  // Close lightbox
  const close = function() {
    if (!window.lightbox) {
      return;
    }

    window.lightbox.parentNode.removeChild(window.lightbox);
    window.lightbox = null;
  };

  // Create lightbox if needed
  const setup = function() {
    if (window.lightbox) {
      return;
    }

    const lightbox = document.createElement('DIV');
    lightbox.className = 'lightbox';
    document.body.appendChild(lightbox);
    window.lightbox = lightbox;

    lightbox.addEventListener('click', function() {
      console.log('click')
      close();
    });
  };

  // Show an image. This expects an `<a>` as its parameter.
  const show = function(element) {
    setup();

    const image = element.children[0].cloneNode(true);
    window.lightbox.appendChild(image);
  }

  // Find all gallery links and make them show the lightbox
  for (let anchor of document.querySelectorAll('div.gallery a')) {
    anchor.addEventListener('click', function(event) {
      event.preventDefault();
      show(anchor);
    });
  }
});

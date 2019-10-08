addLoadEvent(function() {
  if (!document.querySelectorAll) {
    return;
  }

  // Find all gallery anchors
  const anchors = document.querySelectorAll('div.gallery a');

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
    lightbox.setAttribute('tabindex', '-1');

    document.body.appendChild(lightbox);
    window.lightbox = lightbox;

    lightbox.addEventListener('click', function() {
      console.log('click')
      close();
    });

    lightbox.addEventListener('keydown', function(event) {
      // Escape
      if (event.keyCode === 27) {
        close();
        event.preventDefault();
        return;
      }


      // Previous
      if (event.keyCode === 37) {
        showPrevious();
        event.preventDefault();
        return;
      }

      // Next
      if (event.keyCode === 39) {
        showNext();
        event.preventDefault();
        return;
      }
    });

    lightbox.focus();
  };

  // Show an image. This expects an `<a>` as its parameter.
  const show = function(element) {
    if (!element) {
      return;
    }

    setup();

    // Reset
    window.lightbox.innerHTML = '';

    const image = element.children[0].cloneNode(true);
    image.removeAttribute('style');
    window.lightbox.appendChild(image);
  }

  // Find the index of the current lightbox image
  const currentIndex = function() {
    if (!window.lightbox || !window.lightbox.children[0]) {
      return null;
    }

    const src = window.lightbox.children[0].getAttribute('src');
    let index = 0;

    for (let anchor of anchors) {
      if (anchor.children[0].getAttribute('src') === src) {
        return index;
      }

      index += 1;
    }

    return null;
  }

  // Show previous image
  const showPrevious = function() {
    const index = currentIndex();
    if (index === null || index - 1 === -1) {
      return;
    }

    show(anchors[index - 1]);
  };

  // Show next image
  const showNext = function() {
    const index = currentIndex();
    if (index === null || index + 1 === anchors.length) {
      return;
    }

    show(anchors[index + 1]);
  };

  // Find all gallery links and make them show the lightbox
  for (let anchor of anchors) {
    anchor.addEventListener('click', function(event) {
      event.preventDefault();
      show(anchor);
    });
  }
});

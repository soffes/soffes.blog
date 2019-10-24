class Lightbox {
  // Close the lightbox
  close() {
    if (!window.lightbox) {
      return;
    }

    window.lightbox.parentNode.removeChild(window.lightbox);
    window.lightbox = null;
  }

  // Create the elements if needed
  setup() {
    if (window.lightbox) {
      return;
    }

    const lightbox = document.createElement('DIV');
    lightbox.className = 'lightbox';
    lightbox.setAttribute('tabindex', '-1');

    document.body.appendChild(lightbox);
    window.lightbox = lightbox;

    lightbox.addEventListener('keydown', (event) => {
      // Escape
      if (event.keyCode === 27) {
        this.close();
        event.preventDefault();
        return;
      }
    });

    lightbox.addEventListener('click', () => {
      this.close();
    });
  }

  // Show an image. This expects an `<img>` as its parameter.
  show(element) {
    if (!element) {
      return;
    }

    this.setup();

    // Reset
    window.lightbox.innerHTML = '';

    const image = element.cloneNode(true);
    image.removeAttribute('style');
    window.lightbox.appendChild(image);
  }
}


class PhotoGallery extends HTMLElement {
  connectedCallback() {
    for (let image of this._allImages()) {
      image.addEventListener('click', (event) => {
        event.preventDefault();
        new Lightbox().show(image);
      });
    }
  }

  _allImages() {
    return Array.from(this.querySelectorAll('img'));
  }
}
window.customElements.define('photo-gallery', PhotoGallery);


class PhotoGalleryRow extends HTMLElement {
  connectedCallback() {
    this.style.display = "grid";
    this.style.width = "100%";
    this.style.gridGap = "8px";
    this.style.marginBottom = "8px";

    const images = this.querySelectorAll('img');
    if (images.length > 1) {
      let columns = "";
      for (let image of images) {
        columns += "1fr ";
      }

      this.style.gridTemplateColumns = columns;
    }
  }
}
window.customElements.define('photo-gallery-row', PhotoGalleryRow);

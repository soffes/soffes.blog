const lightboxTemplate = document.createElement('template');
lightboxTemplate.innerHTML = `
<style>
:host {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  padding: 32px;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  outline: 0;
  cursor: zoom-out;
}

img {
  max-height: 100%;
  max-width: 100%;
  object-fit: contain;
  cursor: default;
}
</style>
`;
class PhotoLightbox extends HTMLElement {
  constructor() {
    super();

    this.attachShadow({ mode: "open" });
    this.shadowRoot.appendChild(lightboxTemplate.content.cloneNode(true));
  }

  connectedCallback() {
    this.tabIndex = "-1";
  }

  show(image) {
    const exisiting = this.image();
    if (exisiting) {
      exisiting.parentNode.removeChild(exisiting);
    }

    const img = image.cloneNode(true);
    img.removeAttribute('style');
    img.removeAttribute('sizes');
    this.shadowRoot.appendChild(img);
  }

  image() {
    return this.shadowRoot.querySelector('img');
  }
}
window.customElements.define('photo-lightbox', PhotoLightbox);


class LightboxController {
  show(image) {
    this._setup();
    window.lightbox.show(image);
  }

  close() {
    if (!window.lightbox) {
      return;
    }

    window.lightbox.parentNode.removeChild(window.lightbox);
    window.lightbox = null;
  }

  _setup() {
    if (window.lightbox) {
      return;
    }

    const lightbox = document.createElement('photo-lightbox');
    document.body.appendChild(lightbox);
    window.lightbox = lightbox;

    lightbox.addEventListener('keydown', (event) => {
      // Escape
      if (event.keyCode === 27) {
        this.close();
        event.preventDefault();
        return;
      }

      // Previous
      if (event.keyCode === 37) {
        this._showPrevious();
        event.preventDefault();
        return;
      }

      // Next
      if (event.keyCode === 39) {
        this._showNext();
        event.preventDefault();
        return;
      }
    });

    lightbox.addEventListener('click', () => {
      this.close();
    });

    lightbox.focus();
  }

  _allImages() {
    return Array.from(document.querySelectorAll("photo-row")).map((row) => row.images()).flat();
  }

  _currentIndex() {
    if (!window.lightbox) {
      return null;
    }

    const image = window.lightbox.image();
    if (!image) {
      return null;
    }

    const srcs = this._allImages().map((img) => img.getAttribute("src"))
    return srcs.indexOf(image.getAttribute("src"));
  }

  _showPrevious() {
    const index = this._currentIndex();
    if (index === null || index - 1 === -1) {
      return;
    }

    this.show(this._allImages()[index - 1]);
  }

  _showNext() {
    const index = this._currentIndex();
    if (index === null) {
      return;
    }

    const images = this._allImages();
    if (index + 1 === images.length) {
      return;
    }

    this.show(images[index + 1]);
  }
}
const _lightbox = new LightboxController();


class PhotoGallery extends HTMLElement {
  connectedCallback() {
    for (let image of this._allImages()) {
      image.addEventListener('click', (event) => {
        event.preventDefault();
        _lightbox.show(image);
      });
    }
  }

  _allImages() {
    return Array.from(this.querySelectorAll('img'));
  }
}
window.customElements.define('photo-gallery', PhotoGallery);


const rowTemplate = document.createElement('template');
rowTemplate.innerHTML = `
<style>
:host {
  display: grid;
  width: 100%;
  grid-gap: 8px;
  margin-bottom: 8px;
  cursor: zoom-in;
}

img {
  width: 100%;
}

[style*="--aspect-ratio"] > :first-child {
  width: 100%;
}

[style*="--aspect-ratio"] > img {
  height: auto;
}

@supports (--custom:property) {
  [style*="--aspect-ratio"] {
    position: relative;
  }

  [style*="--aspect-ratio"]::before {
    content: "";
    display: block;
    padding-bottom: calc(100% / (var(--aspect-ratio)));
  }

  [style*="--aspect-ratio"] > :first-child {
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
  }
}
</style>`;
class PhotoRow extends HTMLElement {
  constructor() {
    super();

    this.attachShadow({ mode: "open" });
    this.shadowRoot.appendChild(rowTemplate.content.cloneNode(true));
  }

  connectedCallback() {
    const images = this.querySelectorAll("img");
    let columns = "";
    for (let image of images) {
      image.parentNode.removeChild(image);

      const wrapper = document.createElement("div");
      wrapper.style = "--aspect-ratio:" + image.getAttribute("data-width") + "/" + image.getAttribute("data-height")
      wrapper.appendChild(image);
      this.shadowRoot.appendChild(wrapper);
      columns += "1fr ";
    }

    this.style.gridTemplateColumns = columns.trim();
  }

  images() {
    return Array.from(this.shadowRoot.querySelectorAll('img'));
  }
}
window.customElements.define('photo-row', PhotoRow);

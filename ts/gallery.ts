const lightboxTemplate = document.createElement("template");
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
</style>`;

class PhotoLightbox extends HTMLElement {
  constructor() {
    super();

    this.attachShadow({ mode: "open" });
    this.shadowRoot!.appendChild(lightboxTemplate.content.cloneNode(true));
  }

  connectedCallback() {
    this.tabIndex = -1;
  }

  show(image: HTMLElement) {
    const exisiting = this.image();
    if (exisiting) {
      exisiting.parentNode?.removeChild(exisiting);
    }

    const img = image.cloneNode(true) as HTMLElement;
    img.removeAttribute("style");
    img.removeAttribute("srcset");
    img.removeAttribute("sizes");
    this.shadowRoot?.appendChild(img);
  }

  image() {
    return this.shadowRoot?.querySelector("img");
  }
}
window.customElements.define("photo-lightbox", PhotoLightbox);

class LightboxController {
  static shared = new LightboxController();
  static lightbox: PhotoLightbox | null;

  show(image: HTMLElement) {
    this.setup();
    LightboxController.lightbox?.show(image);
  }

  close() {
    if (!LightboxController.lightbox) {
      return;
    }

    LightboxController.lightbox.parentNode?.removeChild(
      LightboxController.lightbox
    );
    LightboxController.lightbox = null;
  }

  private setup() {
    if (LightboxController.lightbox) {
      return;
    }

    const lightbox = document.createElement("photo-lightbox") as PhotoLightbox;
    document.body.appendChild(lightbox);
    LightboxController.lightbox = lightbox;

    lightbox.addEventListener("keydown", (event) => {
      // Close
      if (event.key === "Escape") {
        this.close();
        event.preventDefault();
        return;
      }

      // Previous
      if (event.key === "ArrowLeft") {
        this.showPrevious();
        event.preventDefault();
        return;
      }

      // Next
      if (event.key === "ArrowRight") {
        this.showNext();
        event.preventDefault();
        return;
      }
    });

    lightbox.addEventListener("click", () => {
      this.close();
    });

    lightbox.focus();
  }

  private allImages() {
    const images = Array.from(
      document.querySelectorAll("photo-row")
    ) as PhotoRow[];
    return images.map((row) => row.images()).flat();
  }

  private currentIndex() {
    if (!LightboxController.lightbox) {
      return null;
    }

    const image = LightboxController.lightbox.image();
    if (!image) {
      return null;
    }

    const srcs = this.allImages().map((img) => img.getAttribute("src"));
    return srcs.indexOf(image.getAttribute("src"));
  }

  private showPrevious() {
    const index = this.currentIndex();
    if (index === null || index - 1 === -1) {
      return;
    }

    this.show(this.allImages()[index - 1]);
  }

  private showNext() {
    const index = this.currentIndex();
    if (index === null) {
      return;
    }

    const images = this.allImages();
    if (index + 1 === images.length) {
      return;
    }

    this.show(images[index + 1]);
  }
}

class PhotoGallery extends HTMLElement {
  connectedCallback() {
    this.allImages().forEach((image) => {
      image.addEventListener("click", (event) => {
        event.preventDefault();
        LightboxController.shared.show(image);
      });
    });
  }

  private allImages() {
    return Array.from(this.querySelectorAll("img"));
  }
}
window.customElements.define("photo-gallery", PhotoGallery);

const rowTemplate = document.createElement("template");
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
    this.shadowRoot!.appendChild(rowTemplate.content.cloneNode(true));
  }

  connectedCallback() {
    let columns = "";
    this.querySelectorAll("img").forEach((image) => {
      image.parentNode!.removeChild(image);

      const wrapper = document.createElement("div");
      wrapper.style.setProperty(
        "--aspect-ratio",
        image.getAttribute("data-width") +
          "/" +
          image.getAttribute("data-height")
      );
      wrapper.appendChild(image);
      this.shadowRoot!.appendChild(wrapper);
      columns += "1fr ";
    });

    this.style.gridTemplateColumns = columns.trim();
  }

  images() {
    return Array.from(this.shadowRoot!.querySelectorAll("img"));
  }
}
window.customElements.define("photo-row", PhotoRow);

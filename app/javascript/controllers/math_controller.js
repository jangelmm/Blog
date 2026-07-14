import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (window.renderMathInElement) {
      window.renderMathInElement(this.element, {
        delimiters: [
          { left: "$$", right: "$$", display: true }, 
          { left: "$", right: "$", display: false }  
        ],
        throwOnError: false, 
        output: "html" 
      });
    }
  }
}
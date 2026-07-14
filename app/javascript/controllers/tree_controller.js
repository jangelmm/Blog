import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "explorer" ]

  connect() {
    this.explorerTarget.querySelectorAll(":scope .tree-list > li > strong").forEach(label => {
      label.addEventListener("click", () => {
        const li = label.parentElement;
        li.classList.toggle("is-collapsed");
      });
    });
  }

  search(event) {
    const q = event.target.value.toLowerCase().trim();
    const explorer = this.explorerTarget;
    const allFolders = explorer.querySelectorAll(".tree-list > li");
    const allPosts = explorer.querySelectorAll(".tree-post");

    if (q === "") {
      allFolders.forEach(li => { li.style.display = ""; });
      allPosts.forEach(post => { post.style.display = ""; });
      return;
    }

    allPosts.forEach(post => {
      const matches = post.textContent.toLowerCase().includes(q);
      post.style.display = matches ? "" : "none";
    });

    allFolders.forEach(li => { li.style.display = "none"; });

    let changed = true;
    while (changed) {
      changed = false;
      allFolders.forEach(li => {
        if (li.style.display !== "none") return;

        const ownName = li.querySelector(":scope > strong")?.textContent.toLowerCase() || "";
        const nameMatches = ownName.includes(q);

        const hasVisiblePost = Array.from(li.querySelectorAll(":scope .tree-post"))
          .some(p => p.style.display !== "none");
        const hasVisibleSubfolder = Array.from(li.querySelectorAll(":scope .tree-list > li"))
          .some(sub => sub.style.display !== "none");

        if (nameMatches || hasVisiblePost || hasVisibleSubfolder) {
          li.style.display = "";
          li.classList.remove("is-collapsed"); 
          changed = true;
        }
      });
    }
  }
}
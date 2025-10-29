import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "subCategory"]

  connect() {
    console.log("📦 sub-category controller connecté !");
    this.updateSubCategories();
  }

  updateSubCategories() {
    console.log("🎯 Mise à jour des sous-catégories…");
    const selectedCategory = this.categoryTarget.value;

    const subCategoryOptions = {
      Portfolio: ["Nature", "Portrait", "Photomanipulation Onirique", "Reportage"],
      Boutique: ["Cyanotypie", "Peinture", "Curiosités"],
      Prestation: ["Cyanotypie", "Peinture", "Photographie"]
    };

    const options = subCategoryOptions[selectedCategory] || [];

    this.subCategoryTarget.innerHTML = `<option value="">Choisir une sous-catégorie</option>`;
    options.forEach(sub => {
      const option = document.createElement("option");
      option.value = sub;
      option.textContent = sub;
      this.subCategoryTarget.appendChild(option);
    });
  }
}

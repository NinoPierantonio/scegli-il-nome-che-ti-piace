# Interactive Map – *Short Communication: Satellite tracking of a solitary sperm whale in Greek waters: conservation implications*

This repository hosts the **interactive Leaflet map** accompanying the paper:

> **Panigada, S.**, **Panigada, V.**, **Alberini, A.**, **Godsil, N.**, **Johnson, C.**, **Zanardelli, M.**, and **Pierantonio, N.** **(2026)**.  
> *Short Communication: Satellite tracking of a solitary sperm whale in Greek waters: conservation implications.*  
> *Journal of Cetacean Research and Management, Special Issue 5 (2024–26), DOI: https://doi.org/10.47536/jcrm.v5i1.1119*

🔗 **View the interactive map:** [https://ninopierantonio.github.io/Panigada_etal_JCRM_InteractiveMap/](https://ninopierantonio.github.io/Panigada_etal_JCRM_InteractiveMap/)

---

## 🧭 Authors and Affiliations

- **Simone Panigada** [ORCID: 0000-0003-0856-1227](https://orcid.org/0000-0003-0856-1227) – Tethys Research Institute, Milano, Italy  
- **Viola Panigada** [ORCID: 0009-0003-0719-7790](https://orcid.org/0009-0003-0719-7790) – Tethys Research Institute, Milano, Italy; Duke University Marine Lab, Beaufort, USA  
- **Amalia Alberini** [ORCID: 0009-0003-5210-5875](https://orcid.org/0009-0003-5210-5875) – WWF Greece, Athens, Greece  
- **Nicole Godsil** [ORCID: 0009-0003-0611-7242](https://orcid.org/0009-0003-0611-7242) – WWF Greece, Athens, Greece  
- **Christopher Johnson** [ORCID: 0000-0003-2109-5224](https://orcid.org/0000-0003-2109-5224) – WWF Australia, Melbourne, Australia; Curtin University, Perth, Australia  
- **Margherita Zanardelli** [ORCID: 0000-0003-4043-0745](https://orcid.org/0000-0003-4043-0745) – Tethys Research Institute, Milano, Italy  
- **Nino Pierantonio** [ORCID: 0000-0002-1210-8831](https://orcid.org/0000-0002-1210-8831) – Tethys Research Institute, Milano, Italy  

---

## 📄 Abstract

The Hellenic Trench hosts the highest density of endangered sperm whales in the Eastern Mediterranean Sea and is recognised as an Important Marine Mammal Area (IMMA). This population is exposed to substantial anthropogenic pressures, including vessel strikes, hydrocarbon activities and military exercises. In July 2024, a solitary adult male was equipped with a minimally invasive ARGOS satellite‐linked transmitter southwest of Kefalonia, Greece. Over 57 days, the whale ranged from the Ionian Sea through the Hellenic Trench into the southern and northeastern Aegean Sea. Movement analyses revealed extended periods of localised movements southwest of Kefalonia‐Zakynthos and later in the northeastern Aegean, indicative of potential feeding behaviour, interspersed with phases of directed travel along the Hellenic Trench and across the Cyclades toward the Dodecanese. This is the first satellite track of a male sperm whale in Greece, providing novel insights into habitat use, movement strategies, and previously undocumented transit and residency areas. These findings highlight new key areas for place‐based conservation and demonstrate the value of satellite telemetry for informing targeted management in the Eastern Mediterranean.

---

## 🐋 Keywords
**Sperm whale; *Physeter macrocephalus*; Satellite tagging; Telemetry; Mediterranean Sea; Hellenic Trench; Conservation; Habitat use; Important Marine Mammal Areas (IMMAs)**

---

## 🗺️ Map Information

The interactive map was created in **R** using the [`leaflet`](https://rstudio.github.io/leaflet/) package and exported as a standalone HTML document.  
It visualizes the ARGOS satellite track and associated environmental and spatial data layers for a solitary male sperm whale tagged in Greek waters.

The map includes **selectable and deselectable layers**, allowing users to explore different environmental and spatial datasets relevant to the species’ movements and conservation context:

- **World / Land Polygon**  
  Base polygon layer representing global coastlines.

- **Overall Traffic Density (1 km)** — from [Global Fishing Watch](https://globalfishingwatch.org).  
- **Overall Traffic Density (10 km)** — from [Global Fishing Watch](https://globalfishingwatch.org).  
  > These layers illustrate vessel density patterns at two spatial resolutions.

- **Collision Risk**  
  Modelled spatial layer representing relative vessel strike risk.

- **Sperm Whale Realised Habitat (Kernel Utilization Distributions)**  
  Habitat use derived from the whale’s movement data.

- **Oil & Gas Blocks**  
  Digitised from [Save Greek Seas](https://savegreekseas.com/en/home/).

- **Areas to be Avoided (ATBAs)**  
  Digitised from:  Frantzis A., Leaper R., Alexiadou P., Prospathopoulos A., Lekkas D. (2019).  Shipping routes through core habitat of endangered sperm whales along the Hellenic Trench, Greece: Can we reduce collision risks? PLoS ONE* 14(2): e0212016. [https://doi.org/10.1371/journal.pone.0212016](https://doi.org/10.1371/journal.pone.0212016)

- **Hellenic Trench IMMA (Important Marine Mammal Area)**  
  Obtained from the [Marine Mammal Protected Areas Task Force](https://www.marinemammalhabitat.org/immas/).

- **EU Natura 2000 Sites**  
  Obtained from the [Protected Planet database](https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA).

- **Sperm Whale Home and Core Ranges**  
  Extracted from the whale’s realised habitat data.

- **Sperm Whale Positions by Movement Persistence**  
  Coloured by inferred behavioural states.

- **Sperm Whale Positions by Date**  
  Temporal progression of positions.

- **Sperm Whale Track**  
  The regularised interpolated satellite-derived track of the tagged individual.

These layers together provide a comprehensive visual context linking the whale’s movements to environmental, anthropogenic, and conservation-relevant spatial data in Greek waters.


---

## 🤝 Acknowledgments
The cruise was organised as part of the framework of the project ‘Strengthening Cetacean Research and
Conservation in the Hellenic Trench with the Blue Panda Vessel,’ which is funded by WWF Greece, within the
framework of the ‘Greek Wildlife Alliance’ initiative. The cruise was organised in close collaboration with Nature
Conservation Consultants (NCC), the University of St. Andrews, and the Hellenic Society for the Study and
Protection of the Monk seal (MOm). We are grateful to NCC for the provision of the hydrophone, as well as to
Jonathan Gordon and Kalliopi Gkikopoulou from the University of St. Andrews for their support in the hydrophone
set‐up and operation. Finally, a special thanks goes to WWF France and the crew of the Blue Panda for their
excellent support and contribution.
All research activities, including visual material collection, were conducted with the relevant permits obtained
from the Greek Marine Research Licensing Committee (MRLC) and the Ministry of Environment and Energy, with
the assent of the Natural Environment & Climate Change Agency (NECCA).


---

## 📜 Citation
If referencing this resource, please cite as:  

> Panigada, S., Panigada, V., Alberini, A., Godsil, N., Johnson, C., Zanardelli, M., and Pierantonio, N. 2026. Short Communication: Satellite tracking of a solitary sperm whale in Greek waters: conservation implications. Journal of Cetacean Research and Management, Special Issue 5 (2024–26), DOI: https://doi.org/10.47536/jcrm.v5i1.1119
>  
> Interactive map available at: [https://ninopierantonio.github.io/Panigada_etal_JCRM_InteractiveMap/](https://ninopierantonio.github.io/Panigada_etal_JCRM_InteractiveMap/)

---

## 🪪 Data Availability Statement

The spatial layers presented in this interactive map are provided for visualisation purposes only. Access to the underlying datasets may be granted upon request to the corresponding author(s). Any reuse of the data requires appropriate citation of the associated publication.

---

## 🪪 License
© 2026 Tethys Research Institute and collaborators.  
Distributed for academic and non-commercial use under a [CC BY-NC 4.0 License](https://creativecommons.org/licenses/by-nc/4.0/).

---


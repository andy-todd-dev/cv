This is a project to help me maintain and build my CV in a way that is easy for both humans and LLMs. 

 - The CV content is stored in a markdown file (cv.md) with a simple structure. This makes it easy to edit and maintain.
 - The CV layout is maintained in a LaTeX file (cv-template.latex) which is used in combination with the markdown content to generate a PDF version of the CV. This allows for a professional and consistent appearance.
 - A script (build_pdf.sh) is provided to build the PDF from the markdown and LaTeX files using PanDoc
 - A devcontainer config is provided to easily create and maintain a consistent development environment for working on the CV content and layout.
 - If tooling or dependency changes are required ensure that the devcontainer config is updated to reflect these changes, and that the build script is updated if necessary.
 - A github workflow is provided to automatically build the PDF version of the CV and push it to Google Drive whenever changes are pushed to the repository
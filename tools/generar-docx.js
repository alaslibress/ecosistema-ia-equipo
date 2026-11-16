// Genera documentos-google-skills/*.docx desde guias-equipo/*.md con el formato de la versión anterior.
const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, WidthType,
  BorderStyle, ShadingType, LevelFormat, AlignmentType,
} = require('docx');

const repo = process.argv[2] || path.join(__dirname, '..');
const pares = [
  ['GUIA-PERFIL-1-IT-SEO-VIDEO.md', 'Guia-Perfil-1-IT-SEO-Video.docx'],
  ['GUIA-PERFIL-2-DEV-AGIL-GAS.md', 'Guia-Perfil-2-Dev-Agil-GAS.docx'],
  ['GUIA-PERFIL-3-ARQUITECTURA.md', 'Guia-Perfil-3-Arquitectura.docx'],
  ['GUIA-PERFIL-4-GENERALISTA-OPERATIVO.md', 'Guia-Perfil-4-Generalista-Operativo.docx'],
];

const MARINO = '1F3A5F', CODIGO = 'B03A2E', BORDE = 'BFC7D1', ZEBRA = 'F2F5F9';
const COLS = [3470, 6168];

// Texto en línea: **negrita** y `código`.
function runs(text, base = {}) {
  const out = [];
  const re = /(\*\*[^*]+\*\*|`[^`]+`)/g;
  let last = 0, m;
  while ((m = re.exec(text))) {
    if (m.index > last) out.push(new TextRun({ text: text.slice(last, m.index), ...base }));
    const t = m[0];
    if (t.startsWith('**')) out.push(...runs(t.slice(2, -2), { ...base, bold: true }));
    else out.push(new TextRun({ text: t.slice(1, -1), ...base, font: 'Consolas', color: CODIGO }));
    last = m.index + t.length;
  }
  if (last < text.length) out.push(new TextRun({ text: text.slice(last), ...base }));
  return out;
}

const borde = { style: BorderStyle.SINGLE, size: 4, color: BORDE };
const bordes = { top: borde, bottom: borde, left: borde, right: borde };
const margenes = { top: 60, bottom: 60, left: 100, right: 100 };

function tabla(filas) {
  const celdas = filas.map(l => l.trim().replace(/^\||\|$/g, '').split('|').map(c => c.trim()));
  const [cab, , ...datos] = celdas;
  const fila = (cols, i, header) => new TableRow({
    tableHeader: header,
    children: cols.map((c, j) => new TableCell({
      width: { size: COLS[j], type: WidthType.DXA },
      borders: bordes,
      margins: margenes,
      shading: header ? { fill: MARINO, type: ShadingType.CLEAR, color: 'auto' }
        : (i % 2 === 1 ? { fill: ZEBRA, type: ShadingType.CLEAR, color: 'auto' } : undefined),
      children: [new Paragraph({
        children: header ? [new TextRun({ text: c, bold: true, color: 'FFFFFF', size: 20 })] : runs(c, { size: 20 }),
      })],
    })),
  });
  return new Table({
    width: { size: COLS[0] + COLS[1], type: WidthType.DXA },
    columnWidths: COLS,
    rows: [fila(cab, -1, true), ...datos.map((d, i) => fila(d, i, false))],
  });
}

function convertir(md) {
  const lineas = md.replace(/\r/g, '').split('\n');
  const hijos = [];
  for (let i = 0; i < lineas.length; i++) {
    const l = lineas[i];
    if (!l.trim()) continue;
    if (l.startsWith('# ')) hijos.push(new Paragraph({ style: 'Title', children: [new TextRun(l.slice(2))] }));
    else if (l.startsWith('## ')) hijos.push(new Paragraph({ style: 'Heading1', children: [new TextRun(l.slice(3))] }));
    else if (l.startsWith('|')) {
      const bloque = [];
      while (i < lineas.length && lineas[i].startsWith('|')) bloque.push(lineas[i++]);
      i--;
      hijos.push(tabla(bloque));
      hijos.push(new Paragraph({ children: [] }));
    } else {
      const m = l.match(/^( *)- (.*)$/);
      if (m) hijos.push(new Paragraph({
        numbering: { reference: 'vinetas', level: m[1].length >= 2 ? 1 : 0 },
        spacing: { after: 60 },
        children: runs(m[2]),
      }));
      else hijos.push(new Paragraph({ spacing: { after: 120 }, children: runs(l) }));
    }
  }
  return hijos;
}

function documento(hijos) {
  return new Document({
    styles: {
      default: { document: { run: { font: 'Arial', size: 22 } } },
      paragraphStyles: [
        { id: 'Title', name: 'Title', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { font: 'Arial', bold: true, color: MARINO, size: 40 },
          paragraph: { keepNext: true, spacing: { before: 0, after: 240 },
            border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: MARINO, space: 6 } } } },
        { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { font: 'Arial', bold: true, color: MARINO, size: 28 },
          paragraph: { keepNext: true, spacing: { before: 300, after: 120 }, outlineLevel: 0 } },
      ],
    },
    numbering: { config: [{ reference: 'vinetas', levels: [
      { level: 0, format: LevelFormat.BULLET, text: '●', alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 360, hanging: 260 } } } },
      { level: 1, format: LevelFormat.BULLET, text: '○', alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720, hanging: 260 } } } },
    ] }] },
    sections: [{
      properties: { page: { size: { width: 11906, height: 16838 },
        margin: { top: 1134, right: 1134, bottom: 1134, left: 1134 } } },
      children: hijos,
    }],
  });
}

(async () => {
  for (const [md, docx] of pares) {
    const texto = fs.readFileSync(path.join(repo, 'guias-equipo', md), 'utf8');
    const buf = await Packer.toBuffer(documento(convertir(texto)));
    fs.writeFileSync(path.join(repo, 'documentos-google-skills', docx), buf);
    console.log('ok', docx, buf.length, 'bytes');
  }
})();

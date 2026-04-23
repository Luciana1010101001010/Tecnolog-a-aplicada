Table tabla;

float[] xs;
float[] ys;
int totalPuntos;

String[] palabras = {
 "La huella en la arena",
  "emprende el camino",
  "Sabe que el valle guarda",
  "Siguiendo sus vertientes",
  "entre quebradas y cerros",
  "tocando estrellas en el cielo",
  "Lo oculto"
};

float duracionPausa = 90;
float duracionMovimiento = 90;

// nuevo final más suave
float duracionPenultimaQuieta = 70;
float duracionPenultimaFade = 60;
float duracionVacio = 35;
float duracionFinal = 180;
float duracionFade = 120;

void setup() {
  size(1200, 700);
  frameRate(30);

  tabla = loadTable("recorrido_coquimbo_mamalluca_aprox.csv", "header");

  totalPuntos = tabla.getRowCount();
  xs = new float[totalPuntos];
  ys = new float[totalPuntos];

  float margenX = 200;
  float baseY = 650;

  int i = 0;
  for (TableRow fila : tabla.rows()) {
    float distancia = fila.getFloat("distancia_acumulada_km");
    float altura = fila.getFloat("altura_msnm");

    xs[i] = map(distancia, 0, 81, margenX, width - 250);
    ys[i] = map(altura, 0, 1000, baseY, 100);
    i++;
  }

  textAlign(CENTER, CENTER);
}

void draw() {
  background(245);

  float cicloNormal = duracionPausa + duracionMovimiento;

  // recorre hasta el penúltimo punto
  float tiempoRecorrido = (totalPuntos - 2) * cicloNormal;

  float inicioPenultimaQuieta = tiempoRecorrido;
  float inicioPenultimaFade = inicioPenultimaQuieta + duracionPenultimaQuieta;
  float inicioVacio = inicioPenultimaFade + duracionPenultimaFade;
  float inicioFinal = inicioVacio + duracionVacio;
  float inicioFinalFade = inicioFinal + duracionFinal;

  float cicloCompleto = inicioFinalFade + duracionFade;
  float tiempo = frameCount % int(cicloCompleto);

  float x = 0;
  float y = 0;
  String palabraActual = "";
  float alpha = 255;
  boolean dibujar = true;

  // 1. RECORRIDO NORMAL HASTA EL PENÚLTIMO PUNTO
  if (tiempo < tiempoRecorrido) {
    int tramo = int(tiempo / cicloNormal);
    float tiempoEnTramo = tiempo % cicloNormal;

    if (tiempoEnTramo < duracionPausa) {
      x = xs[tramo];
      y = ys[tramo];
      palabraActual = palabras[tramo];
    } else {
      float t = (tiempoEnTramo - duracionPausa) / duracionMovimiento;
      x = lerp(xs[tramo], xs[tramo + 1], t);
      y = lerp(ys[tramo], ys[tramo + 1], t);
      palabraActual = palabras[tramo + 1];
    }
  }

  // 2. PENÚLTIMA PALABRA QUIETA
  else if (tiempo < inicioPenultimaFade) {
    x = xs[totalPuntos - 2];
    y = ys[totalPuntos - 2];
    palabraActual = palabras[totalPuntos - 2];
  }

  // 3. PENÚLTIMA PALABRA SE DESVANECE
  else if (tiempo < inicioVacio) {
    float t = (tiempo - inicioPenultimaFade) / duracionPenultimaFade;
    x = xs[totalPuntos - 2];
    y = ys[totalPuntos - 2];
    palabraActual = palabras[totalPuntos - 2];
    alpha = lerp(255, 0, t);
  }

  // 4. PEQUEÑO VACÍO
  else if (tiempo < inicioFinal) {
    dibujar = false;
  }

   // 5. "LO OCULTO" APARECE SUAVEMENTE EN EL ÚLTIMO PUNTO
  else if (tiempo < inicioFinalFade) {
    float t = (tiempo - inicioFinal) / duracionFinal;
    x = xs[totalPuntos - 1];
    y = ys[totalPuntos - 1];
    palabraActual = palabras[totalPuntos - 1];
    alpha = lerp(0, 255, t);
  }

  // 6. DESVANECIMIENTO FINAL
  else {
    float t = (tiempo - inicioFinalFade) / duracionFade;
    x = xs[totalPuntos - 1];
    y = ys[totalPuntos - 1];
    palabraActual = palabras[totalPuntos - 1];
    alpha = lerp(255, 0, t);
  }

  if (dibujar) {
    fill(30, 30, 30, alpha);
    textSize(24);
    text(palabraActual, x, y);
  }
}

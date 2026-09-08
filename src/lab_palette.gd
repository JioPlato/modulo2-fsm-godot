## Paleta única do laboratório.
##
## Mantida em um só lugar para que a cor deixe de ser uma constante mágica
## espalhada pelos estados. Cada estado pede a sua cor por nome; trocar a
## identidade visual do laboratório é editar este arquivo, e só ele.
##
## Continuidade com o Módulo I: as mesmas cores usadas lá.
class_name LabPalette
extends RefCounted

const PATRULHAR := Color("#1baf7a")
const PERSEGUIR := Color("#eda100")
const ATACAR    := Color("#d03b3b")
const PROCURAR  := Color("#7a5ec7")
const FUGIR     := Color("#3a3a3a")
const JOGADOR   := Color("#2a78d6")
const PAREDE    := Color("#c9c9c9")
const ROTA      := Color("#b9b9b9")

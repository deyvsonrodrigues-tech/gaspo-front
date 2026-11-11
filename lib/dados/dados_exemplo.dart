import '../modelos/profissional.dart';
import '../modelos/usuario.dart';

// Dados fixos usados pelas telas enquanto não há integração com a API.
// Antes, cada tela mantinha sua própria cópia destas listas.

const Usuario usuarioLogado = Usuario(
  nome: 'João Pedro de Queiroz',
  email: 'paciente123@gmail.com',
  telefone: '(64) 9912-3456',
  endereco: 'Rua das Acácias, nº 245 - Jardim Primavera',
);

const List<Profissional> profissionais = [
  Profissional(
    id: 1,
    nome: 'Dra. Olivia Silva',
    especialidade: 'Cardiologista',
    nota: 4.9,
    totalAvaliacoes: 37,
    status: StatusProfissional.presente,
  ),
  Profissional(
    id: 2,
    nome: 'Dr. Jonathan Figueredo',
    especialidade: 'Dentista',
    nota: 4.9,
    totalAvaliacoes: 37,
    status: StatusProfissional.ocupado,
  ),
  Profissional(
    id: 3,
    nome: 'Dr. Bruno Almeida',
    especialidade: 'Ortopedista',
    nota: 4.9,
    totalAvaliacoes: 37,
    status: StatusProfissional.ausente,
  ),
  Profissional(
    id: 4,
    nome: 'Dra. Larissa Catarina',
    especialidade: 'Ginecologista e Pediatra',
    nota: 4.9,
    totalAvaliacoes: 37,
    status: StatusProfissional.presente,
  ),
  Profissional(
    id: 5,
    nome: 'Dra. Flávia Dávallo',
    especialidade: 'Ortopedista',
    nota: 4.9,
    totalAvaliacoes: 37,
    status: StatusProfissional.ocupado,
  ),
  Profissional(
    id: 6,
    nome: 'Dr. Matheus Castro',
    especialidade: 'Clínico Geral',
    nota: 4.9,
    totalAvaliacoes: 37,
    status: StatusProfissional.presente,
  ),
];

const List<String> especialidades = [
  'Cardiologia',
  'Clínico Geral',
  'Odontologia',
  'Ginecologia',
  'Ortopedia',
  'Pediatria',
];

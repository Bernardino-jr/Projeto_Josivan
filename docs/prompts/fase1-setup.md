Este documento centraliza as interações com a Inteligência Artificial durante a construção da interface do projeto. A IA foi operada estritamente no modelo "Mentor-Mentee" (Sênior para Júnior), focando no aprendizado da arquitetura React, tipagem com TypeScript e componentização, rejeitando a cópia direta de código.

---

## Fase 1: Configuração de Ambiente e Entendimento de Frameworks
* **Prompt:** *"Fiz através do NotebookLM esse projeto, já tenho o VS Code, porém, não sei implementar o ambiente do React, poderia ajudar?"*
  * **Objetivo:** Inicializar o projeto utilizando Vite e React, estruturando as pastas iniciais.
* **Prompt:** *"tailwindcss, o que seria? Como funciona? E porque foi colocado aqui?"*
  * **Objetivo:** Compreender a adoção de classes utilitárias em oposição ao CSS tradicional para prevenir *merge conflicts* no GitHub.
* **Prompt:** *"Como saber qual usar? Você está me dando essas fontes e estilização mas... como saber, caso precise, sem IA."*
  * **Ação Executada:** Instalação do *Tailwind CSS IntelliSense* e leitura da documentação oficial.

## Fase 2: Tipagem Estrita e Versionamento
* **Prompt:** *"Teríamos como alterar para typescript ou seria loucura nesse momento? (...) o professor está usando o Typescript + react..."*
  * **Ação Executada:** Migração do JavaScript para TypeScript (arquivos `.tsx`), alinhando com as exigências da disciplina.
* **Prompt:** *"Não entendi bem o erro... [Envio de imagem com erros 'any' e 'props']"*
  * **Ação Executada:** Criação da primeira `interface` para definir o contrato de dados (Tipagem estrita de Propriedades).
* **Prompt:** *"Preciso atualizar os arquivos do GITHUB, como devo proceder?"*
  * **Ação Executada:** Prática de comandos Git (`add`, `commit`, `push`).

## Fase 3: Dados Dinâmicos e Componentização
* **Prompt:** *"Gostaria então de prosseguir com a criação/edição desse site, por gentileza, não me dê o código pronto, me direcione..."*
  * **Ação Executada:** Desenvolvimento isolado do componente de Card.
* **Prompt:** *"Certo, feito mais essa etapa e qual deve ser o próximo passo?"*
  * **Ação Executada:** Simulação de um banco de dados via array de objetos e uso do método iterativo `.map()` no `App.tsx`.

## Fase 4: Integração de Design UI/UX
* **Prompt:** *"Pedi ao FRAGMA para realizar um esboço. Gostaria da sua avaliação para melhorar ainda mais o que já criamos. O que achou?"*
  * **Ação Executada:** Evolução da interface para um layout profissional de Tabela Acadêmica, refatorando o Card para `LinhaMaterial.tsx` utilizando `CSS Grid` (`grid-cols-5`).

## Fase 5: Estruturação dos Filtros, Flexbox e Desafios de Sintaxe (MVP)
* **Prompt:** *"Partindo do início, o que falta, em termos de front-end? (...) item 1 [Filtros]. Não me vomite código mas instrua-me como um sênior para júnior."*
  * **Objetivo:** Iniciar o componente `Filtros.tsx` usando semântica HTML e Tailwind.
* **Prompt:** *"[Envio de código com a sintaxe incorreta: style={'p-4' 'bg-white'...}]"*
  * **Objetivo/Correção:** Entender a diferença entre a propriedade `style` (CSS in JS) e a propriedade `className` no ecossistema React.
* **Prompt:** *"Não está aparecendo a atualização."*
  * **Objetivo/Correção:** Compreender o ciclo de renderização do React, movendo a chamada `<Filtros />` dos "bastidores" (escopo da função) para o "palco" (dentro do bloco `return`).
* **Prompt:** *"Onde está o erro? Não está bem 'encaixado' na visibilidade. [Envio de imagem]"*
  * **Objetivo/Correção:** Depurar o DOM e corrigir erros de formatação de classes (como o uso da letra "e" para separar classes do Tailwind) e tags HTML não fechadas.
* **Prompt:** *"O texto é muito grande no placeholder ele não fica completo, o que posso fazer para lidar com isso?"*
  * **Ação Executada:** Aplicação de conceitos de UX Mobile-first, diminuindo a fonte (`text-sm`) e tratando o corte de texto de forma elegante (`text-ellipsis`).
* **Prompt:** *"Como faço para fazer uma pequena separação? No CSS puro, usando apenas o MARGIN: 2PX, por exemplo. Mas nesse CSS TAILWIND, como faço?"*
  * **Ação Executada:** Substituição da lógica de margens tradicionais (`ml`, `mr`) pelo uso inteligente da propriedade `gap-4` dentro de contêineres `flex`.
* **Prompt:** *"Ficou uma caixa dentro da outra, muito longa... Teria como diminuir essa caixa?"*
  * **Ação Executada:** Ajuste do *Box Model*, removendo divs aninhadas desnecessárias e limitando a largura do componente (`max-w-2xl` / redução de `padding`).
* **Prompt:** *"Gostaria de pesquisar também por: Formato, Período ou Disciplina. Como fazer isso?"*
  * **Ação Executada:** Implementação da linha secundária de filtros através das tags `<select>` e `<option>`, organizadas lado a lado através de um `grid-cols-3`.

---
**Conclusão do MVP Front-end:**
A aplicação possui agora uma arquitetura componentizada (`App.tsx` gerenciando `Navbar.tsx`, `Filtros.tsx` e `LinhaMaterial.tsx`), tipagem rigorosa para evitar quebras em tempo de execução, e um layout responsivo estruturado puramente via Tailwind CSS, preparado para receber a lógica de estado (`useState`) e o backend em PostgreSQL.

## Fase 6: Versionamento Colaborativo e Arquitetura de Autenticação
* **Prompt:** *"Na verdade, todo esse trabalho não foi adicionado aos colaboradores do projeto. Já fiz o commit e sincronizei."*
  * **Objetivo/Solução:** Compreender o fluxo de trabalho no GitHub em equipe, focando na necessidade de permissões no repositório (Collaborators) e no comando `git pull` para atualizar o ambiente local dos colegas.
* **Prompt:** *"Preciso de duas informações: Qual o BD será usado no REACT? Além disso, caso não haja poderá ser usado o POSTGREESQL?"*
  * **Objetivo:** Definir a arquitetura do sistema. Compreensão de que o React (Front-end) não se conecta diretamente ao PostgreSQL por segurança, necessitando de um intermediário (API ou BaaS como Supabase).
* **Prompt:** *"Como fazer a validação do email? Front ou back? E também como seria o processo?"* / *"E no cadastro, se seria um e-mail válido!?"*
  * **Objetivo:** Estabelecer a estratégia de segurança (Back-end) vs Experiência do Usuário (Front-end). Definição do uso de Single Sign-On (OAuth/Google Auth) focado no domínio acadêmico institucional para evitar cadastros falsos.

## Fase 7: Correções de Árvore DOM (JSX) e Planejamento Final do MVP
* **Prompt:** *"Como resolvo esse problema? [Envio de erro Vite 'Adjacent JSX elements']"*
  * **Objetivo/Correção:** Entender a regra absoluta do React de retornar um único elemento pai por componente, aplicando o uso de Fragmentos React (`<> ... </>`).
* **Prompt:** *"E agora? [Envio de erro 'O elemento JSX div não tem uma marcação de fechamento']"*
  * **Objetivo/Correção:** Depuração de código residual (tags órfãs). Limpeza da árvore DOM para que o Vite pudesse voltar a renderizar a aplicação.
* **Prompt:** *"Certo, preciso dar continuidade, no front-end. Quais são os últimos passos para finalizarmos?"*
  * **Ação Executada:** Definição do *Sprint Backlog* final: 1) Abas de Categoria (Tabs), 2) Gerenciamento de Estado (useState), 3) Modal de Envio e 4) Rodapé.

## Fase 8: Identidade Visual Institucional, Z-Index e Contraste UI/UX
* **Prompt:** *"Certo, façamos o primeiro passo desse projeto. O que será preciso fazer?"*
  * **Ação Executada:** Criação e componentização do arquivo `Tabs.tsx` focado em design condicional (aba ativa vs inativa).
* **Prompt:** *"Preciso dar uma distância maior entre o tabs, filtros e entre Filtros a frase..."*
  * **Ação Executada:** Ajustes de espaçamento usando `margin-bottom` (`mb-8`) do Tailwind CSS.
* **Prompt:** *"Preciso adicionar as cores da universidade UNINASSAU (...) E adicionar essa imagem de modo que fique bem centralizado e distribuído no fundo da tela."*
  * **Objetivo:** Inserir a identidade visual do cliente (Brasão e paleta HEX `#1E3A8A` / `#DC2626`).
* **Prompt:** *"Esse é o script, não houve alterações sobre o fundo da tela. O que houve? Como consertar?"*
  * **Objetivo/Correção:** Resolução de conflitos de Contexto de Empilhamento (*Stacking Context*). Ajuste das propriedades `z-index`, `relative`, `absolute` e `pointer-events-none` para criar a camada de marca d'água corretamente.
* **Prompt:** *"O nome estava errado realmente, porém, preciso dar um destaque maior, está muito apagado. Como fazer isso?"*
  * **Ação Executada:** Manipulação da propriedade `opacity` (opacidade) no Tailwind para equilibrar a visibilidade da marca d'água.
* **Prompt:** *"Preciso destacar os textos da imagem ao fundo. Essa alteração seria das fontes ou apenas nas cores? Ambas? Como proceder?"*
  * **Objetivo:** Refinar a legibilidade e acessibilidade (UX) sobrepondo textos em fundos com imagem, aumentando o "peso" da fonte (`font-medium`) e escurecendo os tons (`text-gray-900`).
* **Prompt:** *"Certo, preciso adicionar as cores da uninassau nesse local [Tabs], o que fazer?"* / *"O itens só aparecem ao passar o mouse por cima, isso está coerente?"*
  * **Objetivo/Correção:** Refatoração do componente `Tabs.tsx` para remover fundos escuros conflitantes e resolver a falha de contraste (texto branco em fundo claro), garantindo a acessibilidade das abas inativas.

  ## Fase 9: Gerenciamento de Estado (useState), Interatividade e Microcopy
* **Prompt:** *"Assim e o que cada coisa faz? [Envio de código inicial do useState]"*
  * **Objetivo/Solução:** Compreender a mecânica do *Hook* `useState`. Definição de como a memória do componente é lida (`abaAtiva`) e como ela deve ser obrigatoriamente atualizada através do *setter* (`setAbaAtiva`), respeitando a imutabilidade do React. Correção da convenção de nomenclatura de variáveis de *snake_case* (`aba_Ativa`) para o padrão da indústria *camelCase* (`abaAtiva`).
* **Prompt:** *"Coloquei conforme instruído e ficou todo em branco. [Envio de erro 'Tela Branca da Morte' do React]"*
  * **Objetivo/Correção:** Resolução de erro fatal de referência (ReferenceError). Entender que o JavaScript é *case-sensitive* e que a divergência de nomenclatura entre a declaração do estado e a sua chamada no `onClick` quebra a árvore de renderização.
* **Prompt:** *"Funcionou, parabéns. Porém, para que isso exatamente? Qual a ideia de se utilizar esse procedimento? E preciso que me explique cada linha..."*
  * **Ação Executada:** Aprofundamento no conceito de injeção dinâmica de CSS. Utilização de *Template Literals* (crases) combinada com o Operador Ternário (`condição ? true : false`) dentro da propriedade `className` para permitir que a interface reaja em tempo real ao clique do usuário, alternando classes do Tailwind CSS sem recarregar a página.
* **Prompt:** *"Prossigamos! / Ao preencher o APP.tsx isso apareceu. [Erro de tipagem no componente pai]"*
  * **Objetivo/Correção:** Implementação do conceito de Elevação de Estado (*Lifting State Up*). Migração da memória do componente filho (`Tabs.tsx`) para o palco principal (`App.tsx`), passando o estado e a função de atualização através de propriedades (*props*). Resolução de erro TypeScript `ts(2322)` ao substituir a passagem incorreta de props por *strings* (aspas) pela correta injeção de variáveis (chaves `{}`). Transformação de `<Tabs/>` em um *Dumb Component* (Componente de Apresentação).
* **Prompt:** *"Preciso alterar esse nome e imagem, para a logo do que já possuo em public e aceito sugestões, ideias para colocar como nome."*
  * **Ação Executada:** Refatoração do arquivo raiz `index.html`. Edição das tags `<title>` e `<link rel="icon">` (Favicon) no `<head>` do documento.
* **Prompt:** *"Preciso que ilustre a ideia de comunidade, dos estudantes como criadores/mantedores."*
  * **Ação Executada:** Aplicação de conceitos de UX Writing através de *Microcopy de Pertencimento*. Criação de um Banner de Comunidade com *Call to Action* (Chamada para Ação) no topo do painel principal para incentivar a colaboração orgânica dos alunos no sistema *Open Source*.
* **Prompt:** *"Achei, muito obrigado. Mas a imagem não foi alterada, apenas o nome. / Ficou bem ruim a visualização, teria um formato adequado?"*
  * **Objetivo/Correção:** Entendimento de engenharia de *assets* para web. Correção do erro de apontamento na propriedade `href` da imagem e adequação da proporção do *Favicon*. Compreensão da necessidade de utilizar arquivos quadrados puros (proporção 1:1, focados apenas no brasão, sem textos anexos) no formato `.png` com fundo transparente para garantir a legibilidade do ícone nas abas dos navegadores.
  ## Fase 10: Lógica do Modal, Renderização Condicional e Resolução de Bugs (Tela Branca)
* **Prompt:** *"Realizado. E agora? E também, o que esse componente está fazendo?"* / *"Eu clico em adicionar materiais e nada acontece. Está corretoe?"*
* **Objetivo/Solução:** Explicação da arquitetura de *Overlay* (sobreposição com `z-index`) do Modal. Religação do fluxo de estado (`abrirModal`) entre o gatilho de clique no componente filho (`Filtros.tsx`) e a renderização condicional (`modalAberto &&`) no componente pai (`App.tsx`).
* **Prompt:** *"[Envio de erro 'Tela Branca da Morte']"* / *"Mudei apenas o nome para Modal e funcionou... porém, eis o resultado [Layout quebrado]"*
* **Objetivo/Correção:** Resolução de erro fatal de referência (*ReferenceError*) no React causado por divergência na nomenclatura de importação de arquivos (`ModalEnvio` vs `Modal.tsx`). Refatoração completa da UI da janela flutuante, aplicando `flex-col` para o empilhamento correto dos elementos e `backdrop-blur` para desfoque de fundo, aprimorando a UX.

## Fase 11: Finalização do Layout (Rodapé) e Tratamento de Conflitos Visuais
* **Prompt:** *"Funcionou perfeitamente, porém, a uma linha em cima do nome UNINASSAU e está atrapalhando... Removendo ou abaixando essa linha?"* / *"Na verdade, aumentou ainda mais a cor."*
* **Objetivo/Correção:** Criação do componente estático `Rodape.tsx`. Resolução de comportamento padrão do Tailwind CSS, onde a remoção da classe de cor mantendo o eixo (`border-t`) gerava uma linha sólida preta indesejada. Discussão técnica sobre design responsivo e o conflito entre o redimensionamento fluido de imagens de fundo (`bg-contain`) e elementos fixos do DOM, optando por um design *borderless* (sem linha) para máxima compatibilidade entre telas.

## Fase 12: Planejamento de Rotas (React Router) e Refatoração da Navbar
* **Prompt:** *"A tela de login que será a primeira... não é front end? Se for ser usada, no componente navbar, não deverá haver login, apenas o nome repositório, não é?"*
* **Objetivo/Solução:** Planejamento arquitetural para a transição de SPA simples para múltiplas rotas utilizando *React Router*, separando Layout de Autenticação (público) do Layout do Acervo (privado).
* **Prompt:** *"tenho o link oficial, do portal do aluno da instituição..."* / *"Ao invés do entrar com o Google, usar o link para acessar o portal."*
* **Ação Executada:** Refatoração do componente `Navbar.tsx` com foco em minimalismo e integração ao ecossistema institucional. Implementação de um botão de redirecionamento seguro (`target="_blank" rel="noopener noreferrer"`) para o ADFS oficial da faculdade.
## Fase 13: Controle de Versão (GitHub), Instalação do React Router e Reestruturação de Pastas
* **Prompt:** *"Como vejo as versões, no caso, de cada commit e conseguiria acessar as versões antes de cada commit? No ambiente GITHUB."*
* **Objetivo/Solução:** Compreensão do fluxo de rastreabilidade no GitHub, incluindo a consulta ao histórico de *commits*, análise de alterações (*diffs*) e navegação em versões anteriores do código através da opção de visualização do repositório por *commit* (`< >`).
* **Prompt:** *"Certo, creio que será necessário a instalação do react-router agora, certo? Afinal, para finalizarmos o front, antes será preciso a criação da tela de login/cadastro."* / *"No caso, devo apagar o App.tsx? já copiei e também adicionei os pontos extras no apontamento dos respectivos diretórios."*
* **Ação Executada:** Instalação da biblioteca `react-router-dom` e reorganização arquitetural do projeto, separando blocos reutilizáveis (`src/components`) de telas completas (`src/Pages`). Migração da interface do acervo para `Repositorio.tsx` e criação da página `Login.tsx`.
* **Prompt:** *"Está dando erro, embora já tenha corrigido e colocado a primeira maiúscula. [Envio de erros TypeScript ts(2307) e ts(2614)]"*
* **Objetivo/Correção:** Resolução de conflito de *case-sensitivity* no ambiente Linux (GitHub Codespaces), corrigindo a extensão do arquivo de `Login.Tsx` para `Login.tsx`, além da padronização da exportação nomeada (`export function Repositorio`) para corrigir a importação no roteador.

## Fase 14: Construção da Tela de Login, Navegação Programática e Identidade Visual
* **Prompt:** *"Funcionou, ao colocar: /login e /repositório, fui redirecionado para as páginas."* / *"Preciso fazer o mesmo que o repositório, tenho que colocar a imagem da universidade ao fundo."*
* **Ação Executada:** Implementação do formulário de autenticação em `Login.tsx` (campos de matrícula e senha) utilizando o *Hook* `useNavigate` no evento `onSubmit` para redirecionamento automático ao `/repositorio`. Aplicação da marca d'água institucional em camada de fundo (`absolute`, `opacity-10`, `pointer-events-none`) com destaque e legibilidade do cartão via `backdrop-blur-sm` e `z-10`.
* **Prompt:** *"[Envio de erro Vite/OXC: PARSE_ERROR Unexpected token na linha 76]"*
* **Objetivo/Correção:** Correção de erro de sintaxe JSX causado pelo fechamento incompleto das tags finais (`</div>`, `);`, `}`) ao atualizar a estrutura do `<main>` em `Login.tsx`.

## Fase 15: Refatoração para `Rotas.tsx`, Rota de Fallback (`<Navigate />`) e Conclusão do Front-end
* **Prompt:** *"Ao não colocar nada, sou direcionado a tela de login, porém, ao colocar/login, a tela fica em branco."* / *"Tá tudo tela branca agora [Envio de prints de Rotas.tsx e tela branca]"*
* **Objetivo/Correção:** Reestruturação de `App.tsx` para `Rotas.tsx` e atualização da importação nomeada no ponto de entrada `main.tsx` (eliminando a tela branca). Inclusão da rota explícita `/login` e da rota de segurança coringa (`path="*"`) com `<Navigate to="/" />` para impedir telas vazias em URLs inválidas.
* **Prompt:** *"[Envio de print com erro de referência no componente Navigate em Rotas.tsx]"*
* **Objetivo/Correção:** Adição do componente `Navigate` à declaração de importação do `react-router-dom` na primeira linha de `Rotas.tsx`.
* **Prompt:** *"Certo, o que o navegate faz exatamente?"* / *"Em outras palavras, o uso do Navigate, assegura que por um erro de digitação e/ou erro na paginação, o usuário seja levado sempre para a primeira tela..."* / *"Bom, coloquei o /repositório e fui direcionado para a tela, creio que deva ser feito o back-end para validar essa segurança..."*
* **Objetivo/Solução:** Alinhamento conceitual entre `<Navigate />` (redirecionamento declarativo de rotas) e `useNavigate()` (navegação programática acionada por eventos). Definição da separação de responsabilidades entre bloqueio de interface (Front-end) e validação real de credenciais/tokens (Back-end + PostgreSQL), encerrando a etapa estrutural do Front-end.

## Fase 16: Encerramento do Front-end e Passagem de Bastão (Handoff para Back-end)
* **Prompt:** *"A partir de agora, será dado o sistema/projeto a outro integrante. Ele será o responsável direto e completo de toda a parte back-end. Preciso que crie um prompt detalhando tudo o que foi feito, por exemplo: Linguagem, IDE, Frameworks, Bibliotecas, tudo que pode e foi usado até agora... Coloque esse prompt que está sendo pedido também no resumo a ser entregue ao professor, preciso que ele saiba que a partir de agora, outro irá assumir o controle da 'embarcação'."*
* **Objetivo/Ação Executada:** Conclusão formal do ciclo de desenvolvimento do Front-end e transição de liderança técnica (*Handoff*) para o integrante responsável pela arquitetura de Back-end e Banco de Dados (PostgreSQL). Elaboração de um *Prompt de Transferência de Contexto* contendo todo o inventário tecnológico utilizado (GitHub Codespaces, Vite, React, TypeScript, Tailwind CSS e React Router), o mapeamento completo de diretórios (`Rotas.tsx`, `Pages` e `components`), o estado atual dos dados simulados e as diretrizes pedagógicas de co-criação com a IA. Registro oficial da divisão de responsabilidades no projeto acadêmico, documentando que as próximas fases (API, autenticação, persistência de dados e integração) serão conduzidas sob nova autoria.

## Fase 17: Alinhamento Arquitetural e Isolamento do Ambiente Back-end
* *Prompt:* "gemini, to fazendo um trabalho da faculdade em grupo. usando a linguagem react + typescript, react router dom. eu fiquei c a parte de back end. estamos usando o codespace (...) eu quero que me ajude apenas com a parte do back end, deixando toda a parte do banco de fora. ela ta sendo feita por outra pessoa."
* *Objetivo/Solução:* Auditoria da estrutura do Front-end (Rotas.tsx, Login.tsx, Repositorio.tsx, Modal.tsx) confrontada com as regras de negócio e o Modelo Relacional. Separação oficial de responsabilidades entre Front-end, Back-end e Banco de Dados (Supabase). Criação da pasta isolada backend/ no GitHub Codespaces para gerenciar dependências e compilação do servidor sem interferir no ambiente Vite/React.
* *Ação Executada:* Inicialização do projeto Node.js (npm init -y), criação do diretório backend/src, instalação das dependências de servidor (express, cors, dotenv, @supabase/supabase-js, bcryptjs, jsonwebtoken, multer) e de tipagem/desenvolvimento (typescript, tsx, @types/*).

## Fase 18: Configuração Estrita do TypeScript, Variáveis de Ambiente e Servidor HTTP
* *Prompt:* "ta certo ? / podemos seguir ? / aq no caso né ? se sim, por favor, consegue me mandar o json limpo dnv ? / ta dando erro / assim ?" [Envio de prints de terminal e configuração de arquivos no VS Code]
* *Objetivo/Correção:* Substituição do tsconfig.json padrão por configuração limpa voltada ao Node.js com strict: true e forceConsistentCasingInFileNames: true (prevenindo erros de case-sensitivity no ambiente Linux do Codespaces). Resolução de duplicação de chaves JSON no backend/package.json e configuração dos scripts dev, build e start. Blindagem do .gitignore na raiz para impedir o versionamento acidental de arquivos .env.
* *Ação Executada:* Criação e configuração dos arquivos .env, .env.example, src/config/supabase.ts (cliente de conexão resiliente com o Supabase) e src/server.ts com middlewares globais (cors e express.json) e endpoint de diagnóstico GET /api/health. Inicialização bem-sucedida do servidor na porta 3333 via tsx watch

## Fase 19: Rotas MVP de Materiais, Upload de Arquivos (Multer + Storage) e Moderação
* **Prompt:** *"ta tudo certo ? [Envio de prints confirmando authMiddleware.ts, authRoutes.ts e server.ts]"*
* **Objetivo/Solução:** Construção das operações centrais do repositório acadêmico seguindo práticas de *Clean Code* (constantes semânticas para regras de negócio, funções auxiliares puras como `gerarNomeUnicoArquivo` e *Early Return*). Garantia de validação rigorosa de tamanho máximo (10 MB) e tipos MIME permitidos (PDF, JPG, JPEG, PNG e TXT), além do fluxo de moderação com histórico.
* **Ação Executada:** Criação do arquivo `src/routes/materialRoutes.ts` com endpoints `GET /api/materiais` (listagem filtrada de materiais aprovados), `POST /api/materiais` (upload protegido via JWT e `multer` com persistência no Supabase Storage e tabelas `material`/`arquivo`) e `PATCH /api/materiais/:id/status` (aprovação/rejeição com registro na tabela `moderacao`). Integração final das rotas no `src/server.ts`.
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
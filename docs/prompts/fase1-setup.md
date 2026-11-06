# Registro Arquitetural e Prompts Utilizados (Defesa de Projeto ADS)

Este documento centraliza as interações guiadas com Inteligência Artificial que moldaram a engenharia do Repositório Acadêmico. A IA foi utilizada estritamente no modelo de "mentor-mentee", com foco na compreensão da arquitetura do código e não em cópia direta. Ele está estruturado para demonstrar à banca avaliadora a evolução do raciocínio lógico, a aplicação de tipagem estrita e a componentização.

## Fase 1: Configuração de Ambiente e Entendimento de Frameworks

* **Prompt:** *"Fiz através do NotebookLM esse projeto, já tenho o VS Code, porém, não sei implementar o ambiente do React, poderia ajudar?"*
  * **Objetivo:** Inicializar o projeto utilizando Vite e React, estruturando as pastas iniciais de componentes (`Navbar`, `Filtros`).

* **Prompt:** *"tailwindcss, o que seria? Como funciona? E porque foi colocado aqui?"*
  * **Objetivo:** Compreender a injeção do framework de CSS.
  * **Justificativa Técnica:** Adoção de classes utilitárias para evitar gargalos de escalabilidade e prevenir conflitos de mesclagem (merge conflicts) no repositório.

* **Prompt:** *"Certo, porém, essa aplicação inline, não seria ruim para futuras correções? O ideal seria uma página única, com todas as estilizações, não seria?"*
  * **Objetivo:** Desafiar a arquitetura do Tailwind contra o modelo tradicional de CSS global.
  * **Justificativa Técnica:** Compreensão de que no ecossistema React, o estilo deve ser encapsulado (*Single Source of Truth*) junto com a lógica do componente, eliminando o "CSS morto" quando componentes são removidos.

* **Prompt:** *"Como saber qual usar? Você está me dando essas fontes e estilização mas... como saber, caso precise, sem IA."*
  * **Objetivo:** Eliminar a dependência de geração de código estético.
  * **Ação Executada:** Instalação e uso da extensão *Tailwind CSS IntelliSense* no VS Code e consulta à documentação oficial para mapeamento de atributos lógicos (ex: `mt-8`, `p-4`).

## Fase 2: Refatoração, Tipagem Estrita e Versionamento

* **Prompt:** *"Teríamos como alterar para typescript ou seria loucura nesse momento? (...) o professor está usando o Typescript + react..."*
  * **Objetivo:** Migrar o ecossistema de JavaScript puro para TypeScript.
  * **Ação Executada:** Reconfiguração do `tsconfig.json` e alteração das extensões para `.tsx`, alinhando o projeto às exigências acadêmicas de desenvolvimento seguro.

* **Prompt:** *"Não entendi bem o erro... [Envio de imagem com erros 'any' e 'props' no VS Code]"*
  * **Objetivo:** Depurar erros de compilação do TypeScript.
  * **Ação Executada:** Criação da primeira `interface` (`Titulus`) para definir o contrato de dados das propriedades, resolvendo o erro de tipo implícito `any`.

* **Prompt:** *"Preciso atualizar os arquivos do GITHUB, como devo proceder? Afinal, agora estamos no React/TypeScript."*
  * **Objetivo:** Versionar a migração estrutural.
  * **Ação Executada:** Utilização de comandos Git (`add`, `commit`, `push`) com padronização de commits semânticos (`refactor:`, `docs:`, `feat:`).

## Fase 3: Componentização e Fluxo de Dados Dinâmico

* **Prompt:** *"Gostaria então de prosseguir com a criação/edição desse site, por gentileza, não me dê o código pronto, me direcione..."*
  * **Objetivo:** Construir o primeiro componente isolado aplicando as regras de tipagem e estilização aprendidas.
  * **Ação Executada:** Desenvolvimento do `CardMaterial.tsx`.

* **Prompt:** *"Certo, feito mais essa etapa e qual deve ser o próximo passo?"*
  * **Objetivo:** Evoluir de dados estáticos para renderização de listas dinâmicas.
  * **Ação Executada:** Criação de um array de objetos simulando o banco de dados e implementação do método iterativo `.map()` no `App.tsx`, com a inclusão obrigatória da `key` no React.

## Fase 4: Integração de Design UI/UX e Estruturas de Grade (Grid)

* **Prompt:** *"Pedi ao FRAGMA para realizar um esboço. Gostaria da sua avaliação para melhorar ainda mais o que já criamos. O que achou? [Envio do mockup com formato de tabela]"*
  * **Objetivo:** Elevar o padrão visual da interface para um layout de tabela profissional.

* **Prompt:** *"Pela que julgar melhor para o aprendizado/desenvolvimento. Só peço que não me dê códigos prontos, me oriente, me guie..."*
  * **Objetivo:** Executar a refatoração do Card para uma Linha de Tabela.
  * **Ação Executada:** Evolução da interface para `interface Material` (adicionando formato e período) e reestruturação do componente usando CSS Grid (`grid-cols-5`) no arquivo `LinhaMaterial.tsx` para alinhamento simétrico das colunas.

* **Prompt:** *"Na verdade, por hoje, é só (...) Gostaria que revisar todo o código construído hoje e a razão do porquê de cada escolha, por favor. Principalmente no tocante ao css."*
  * **Objetivo:** Consolidar a teoria por trás da prática executada para preparação da sabatina, revisando as escolhas arquiteturais entre React, TypeScript e Tailwind.
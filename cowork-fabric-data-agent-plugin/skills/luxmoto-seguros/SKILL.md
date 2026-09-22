---
name: luxmoto-seguros
description: |
  Consulta dados de seguros de motocicletas da LuxMoto Seguros usando o Data Agent
  do Microsoft Fabric, fundamentado na ontologia Fabric IQ. Use quando o usuário
  pedir informações sobre apólices, clientes
  segurados, motos, marcas, modelos, status, classes de risco, valores segurados,
  coberturas contratadas, filtros, totais, agrupamentos ou tabelas.
---

# Consultas de seguros da LuxMoto

Use o conector **Data Agent de seguros da LuxMoto** para responder perguntas fundamentadas na ontologia de seguros de motocicletas.

## Quando usar

Acione o conector para solicitações que envolvam um ou mais destes conceitos:

- apólice e status da apólice;
- cliente ou segurado;
- motocicleta, marca e modelo;
- classe de risco;
- valor segurado;
- cobertura contratada;
- relacionamento entre essas entidades;
- filtros, contagens, totais, agrupamentos e tabelas.

## Procedimento

1. Identifique as entidades, os campos, os filtros e o formato solicitados.
2. Chame a ferramenta `DataAgent_Data_Agent_Fabric_LuxMotoSeguros` do conector **Data Agent de seguros da LuxMoto**.
3. Envie ao Data Agent a pergunta completa, preservando os campos, filtros e o formato solicitados.
4. Aplique os filtros exatamente como solicitados. Para status, preserve os valores definidos na ontologia, como `Ativa`, quando disponíveis.
5. Retorne somente campos sustentados pelos resultados das ferramentas.
6. Quando o usuário pedir uma tabela, use uma tabela Markdown com uma coluna para cada campo solicitado.
7. Informe de forma objetiva quando não houver registros correspondentes.

## Regras

- Não responda consultas de seguros usando conhecimento geral quando os dados deveriam vir da ontologia.
- Não invente apólices, clientes, motos, coberturas, valores ou classificações.
- Não substitua um campo solicitado por outro semelhante sem avisar.
- Não remova filtros definidos pelo usuário.
- Se as ferramentas do conector não estiverem disponíveis, informe que a conexão com a ontologia não está acessível.
- Se uma entidade ou propriedade não existir na ontologia, informe qual elemento não foi encontrado.

## Exemplos de acionamento

- "Eu preciso de uma tabela com a apólice, somente status Ativa, o nome do cliente, o modelo da moto, a classe de risco e o valor segurado."
- "Quais coberturas foram contratadas para motos BMW?"
- "Liste as apólices ativas por classe de risco."
- "Qual é o valor segurado total por marca de motocicleta?"
- "Mostre os clientes com motos de alto risco e suas coberturas."

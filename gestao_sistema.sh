#!/bin/bash

# Verifica se o script está sendo executado como root (necessário para useradd)
# O comando 'id -u' retorna 0 se o usuário for o root.
if [ "$(id -u)" -ne 0 ]; then
    echo "Por favor, execute este script com sudo: sudo ./gestao_sistema.sh"
    exit 1
fi

# Variável global para o diretório base
BASE_DIR="/home/unip/UnipSolutions"
# Arquivo para registrar os usuários criados no item 2
ARQ_USUARIOS="$BASE_DIR/usuarios_cadastrados.txt"

# Loop infinito para o menu interativo (Laço de repetição: while)
while true; do
    # O comando 'clear' limpa a tela do terminal
    clear
    
    # Comandos 'echo' imprimem texto na tela
    echo "========================================================="
    echo "          SISTEMA DE GESTÃO - UNIP SOLUTIONS             "
    echo "========================================================="
    echo "1. Criação de Estrutura de Diretórios"
    echo "2. Cadastro de Usuários"
    echo "3. Listagem de usuários e Relatório"
    echo "4. Verificação de Arquivos"
    echo "5. Backup Automatizado"
    echo "6. Busca Inteligente"
    echo "7. Loop de Processamento (Info Membros)"
    echo "8. Sair"
    echo "========================================================="
    
    # O comando 'read' recebe a entrada do usuário e salva na variável 'opcao'
    read -p "Escolha uma opção (1-8): " opcao

    # Estrutura condicional 'case' para tratar o menu
    case $opcao in
        1)
            echo -e "\n--- 1. Criação de Estrutura de Diretórios ---"
            # 'mkdir -p' cria diretórios e subdiretórios; não dá erro se já existirem
            mkdir -p "$BASE_DIR/Membros_grupos"
            
            read -p "Digite os nomes dos membros do grupo separados por espaço (ex: Joao Maria Pedro): " membros
            
            # Laço 'for' para percorrer cada nome digitado
            for membro in $membros; do
                DIR_MEMBRO="$BASE_DIR/Membros_grupos/$membro"
                mkdir -p "$DIR_MEMBRO"
                echo "Diretório $DIR_MEMBRO criado."
            done
            
            # 'chmod 757' altera permissões: Owner(7=rwx), Group(5=r-x), Others(7=rwx)
            # O parâmetro '-R' aplica a mudança recursivamente
            chmod -R 757 "$BASE_DIR"
            echo "Permissões configuradas (Owner: rwx, Group: rx, Others: rwx)."
            read -p "Pressione ENTER para continuar..."
            ;;

        2)
            echo -e "\n--- 2. Cadastro de Usuários ---"
            # Cria o diretório base para não dar erro ao salvar o txt, se a opção 1 não foi rodada
            mkdir -p "$BASE_DIR" 
            
            # Laço que roda até que o usuário digite "sair"
            while true; do
                read -p "Digite o nome do novo usuário (ou digite 'sair' para encerrar): " nome_usuario"
                nome_usuario="${nome_usuario// /_}"
                
                # Estrutura condicional 'if'
                if [ "$nome_usuario" == "sair" ]; then
                    break # Sai do laço
                fi
                
                # 'useradd -m' cria o usuário e também a pasta home (/home/nome_usuario)
                useradd -m "$nome_usuario" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    echo "Usuário $nome_usuario criado com sucesso!"
                    
                    # Cria um arquivo com informações fictícias na home do usuário
                    ARQ_INFO="/home/$nome_usuario/info.txt"
                    echo "$nome_usuario:" > "$ARQ_INFO"
                    echo "Cargo - Analista de Sistemas" >> "$ARQ_INFO"
                    echo "Departamento - TI 202" >> "$ARQ_INFO"
                    
                    # Salva o nome do usuário cadastrado na lista para usar no item 3
                    echo "$nome_usuario" >> "$ARQ_USUARIOS"
                else
                    echo "Erro: Usuário $nome_usuario pode já existir."
                fi
            done
            ;;

        3)
            echo -e "\n--- 3. Listagem de usuários e Relatório ---"
            # Verifica se o arquivo de usuários existe (-f)
            if [ -f "$ARQ_USUARIOS" ]; then
                echo "Usuários cadastrados no Item 2:"
                # 'cat' exibe o conteúdo do arquivo
                cat "$ARQ_USUARIOS"
                
                ARQ_RELATORIO="$BASE_DIR/relatorio.txt"
                # Esvazia ou cria o arquivo de relatório
                > "$ARQ_RELATORIO" 
                
                echo "Gerando relatório dos diretórios criados..."
                # Lê o arquivo linha por linha
                while IFS= read -r user; do
                    DIR_USER="/home/$user"
                    if [ -d "$DIR_USER" ]; then
                        # 'stat' pega informações detalhadas; '%w' ou '%z' pega a data de criação/modificação
                        DATA_CRIACAO=$(stat -c %y "$DIR_USER" | cut -d' ' -f1)
                        echo "Diretório: $DIR_USER | Data de Criação: $DATA_CRIACAO" >> "$ARQ_RELATORIO"
                    fi
                done < "$ARQ_USUARIOS"
                
                echo "Relatório salvo em: $ARQ_RELATORIO"
                # Exibe o relatório gerado
                cat "$ARQ_RELATORIO"
            else
                echo "Nenhum usuário foi cadastrado ainda (via script)."
            fi
            read -p "Pressione ENTER para continuar..."
            ;;

        4)
            echo -e "\n--- 4. Verificação de Arquivos ---"
            read -p "Digite o caminho completo do arquivo para verificar: " nome_arquivo
            
            # Condicionais: -f (é arquivo?), -d (é diretório?)
            if [ -f "$nome_arquivo" ]; then
                echo "Resultado: '$nome_arquivo' é um ARQUIVO existente."
            elif [ -d "$nome_arquivo" ]; then
                echo "Resultado: '$nome_arquivo' é um DIRETÓRIO existente."
            else
                echo "Resultado: Inexistente. Criando o arquivo agora..."
                # 'touch' cria um arquivo vazio
                touch "$nome_arquivo"
                echo "Arquivo '$nome_arquivo' criado com sucesso!"
            fi
            read -p "Pressione ENTER para continuar..."
            ;;

        5)
            echo -e "\n--- 5. Backup Automatizado ---"
            read -p "Digite o diretório de origem (ex: /home/unip): " dir_origem
            read -p "Digite o nome do arquivo de origem (ex: arquivo.txt): " arq_origem
            read -p "Digite o diretório de destino (ex: /tmp): " dir_destino
            
            # Verifica se o arquivo de origem existe
            if [ -f "$dir_origem/$arq_origem" ]; then
                # Verifica se o destino não existe e o cria, caso necessário
                if [ ! -d "$dir_destino" ]; then
                    mkdir -p "$dir_destino"
                fi
                # 'cp' copia o arquivo
                cp "$dir_origem/$arq_origem" "$dir_destino/"
                echo "Backup realizado: $arq_origem copiado para $dir_destino"
            else
                echo "Erro: O arquivo de origem não foi encontrado."
            fi
            read -p "Pressione ENTER para continuar..."
            ;;

        6)
            echo -e "\n--- 6. Busca Inteligente ---"
            read -p "Digite a extensão a ser buscada (ex: txt, sh, conf sem o ponto): " extensao
            read -p "Digite o diretório de origem para a busca: " dir_busca
            
            if [ -d "$dir_busca" ]; then
                echo "Buscando arquivos com extensão .$extensao em $dir_busca..."
                # 'find' procura arquivos de forma inteligente
                # 2>/dev/null oculta mensagens de erro de permissão negada
                find "$dir_busca" -type f -name "*.$extensao" 2>/dev/null
            else
                echo "Erro: O diretório de busca informado não existe."
            fi
            read -p "Pressione ENTER para continuar..."
            ;;

        7)
            echo -e "\n--- 7. Loop de Processamento ---"
            ARQ_INFO_MEMBROS="$BASE_DIR/info_membros.txt"
            DIR_MEMBROS="$BASE_DIR/Membros_grupos"
            
            if [ -d "$DIR_MEMBROS" ]; then
                > "$ARQ_INFO_MEMBROS" # Limpa/cria o arquivo
                
                # Laço 'for' varrendo tudo dentro do diretório de membros
                for dir in "$DIR_MEMBROS"/*; do
                    if [ -d "$dir" ]; then
                        # Extrai as informações usando o comando 'stat'
                        NOME_DIR=$(basename "$dir")
                        PERMISSOES=$(stat -c %a "$dir")
                        DATA_CRIACAO=$(stat -c %y "$dir" | cut -d' ' -f1)
                        
                        # Formata as informações
                        INFO="Diretório: $NOME_DIR | Permissões: $PERMISSOES | Data: $DATA_CRIACAO"
                        
                        # Exibe na tela e salva no arquivo
                        echo "$INFO"
                        echo "$INFO" >> "$ARQ_INFO_MEMBROS"
                    fi
                done
                echo -e "\nInformações salvas em $ARQ_INFO_MEMBROS"
            else
                echo "O diretório $DIR_MEMBROS não existe. Execute a opção 1 primeiro."
            fi
            read -p "Pressione ENTER para continuar..."
            ;;

        8)
            echo "Encerrando o sistema. Até logo!"
            # Sai do script com código de sucesso
            exit 0 
            ;;
            
        *)
            # Tratamento para qualquer opção que não seja de 1 a 8
            echo "Opção inválida! Pressione ENTER para tentar novamente."
            read
            ;;
    esac
done

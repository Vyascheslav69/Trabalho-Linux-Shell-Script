#!/bin/bash

BASE_DIR="/home/unip/UnipSolutions"
ARQ_USUARIOS="$BASE_DIR/usuarios_cadastrados.txt"

while true; do
    clear
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
    
    echo "Escolha uma opção (1-9):"
    read -p "> " opcao

    case $opcao in
        1)
            echo -e "\n--- 1. Criação de Estrutura de Diretórios ---"
            mkdir -p "$BASE_DIR/Membros_grupos"
            
            echo "Digite os nomes dos membros separados por VÍRGULA (ex: Joao Silva, Maria, Jose):"
            read -p "> " entrada_membros
            
            OLD_IFS=$IFS
            IFS=','
            
            for membro in $entrada_membros; do
                membro=$(echo "$membro" | xargs)
                if [ -n "$membro" ]; then
                    membro_dir="${membro// /_}"
                    DIR_MEMBRO="$BASE_DIR/Membros_grupos/$membro_dir"
                    mkdir -p "$DIR_MEMBRO"
                    echo "Diretório para '$membro' configurado em: $membro_dir"
                fi
            done
            
            IFS=$OLD_IFS
            chmod -R 757 "$BASE_DIR"
            echo "Permissões configuradas (757)."
            
            echo "Pressione ENTER para continuar..."
            read
            ;;

        2)
            echo -e "\n--- 2. Cadastro de Usuários ---"
            mkdir -p "$BASE_DIR" 
            
            while true; do
                echo "Digite o nome do novo usuário (ou 'sair'):"
                read -p "> " nome_usuario
                
                if [ "$nome_usuario" == "sair" ]; then
                    break
                fi

                nome_usuario="${nome_usuario// /_}"
                useradd -m "$nome_usuario" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    echo "Usuário $nome_usuario criado com sucesso!"
                    ARQ_INFO="/home/$nome_usuario/info.txt"
                    echo "$nome_usuario:" > "$ARQ_INFO"
                    echo "Cargo - Analista de Sistemas" >> "$ARQ_INFO"
                    echo "Departamento - TI 202" >> "$ARQ_INFO"
                    echo "$nome_usuario" >> "$ARQ_USUARIOS"
                else
                    echo "Erro: Usuário $nome_usuario pode já existir."
                fi
            done
            ;;

        3)
            echo -e "\n--- 3. Listagem de usuários e Relatório ---"
            if [ -f "$ARQ_USUARIOS" ]; then
                echo "Usuários cadastrados no Item 2:"
                cat "$ARQ_USUARIOS"
                
                ARQ_RELATORIO="$BASE_DIR/relatorio.txt"
                > "$ARQ_RELATORIO" 
                
                while IFS= read -r user; do
                    DIR_USER="/home/$user"
                    if [ -d "$DIR_USER" ]; then
                        DATA_CRIACAO=$(stat -c %y "$DIR_USER" | cut -d' ' -f1)
                        echo "Diretório: $DIR_USER | Data de Criação: $DATA_CRIACAO" >> "$ARQ_RELATORIO"
                    fi
                done < "$ARQ_USUARIOS"
                cat "$ARQ_RELATORIO"
            else
                echo "Nenhum usuário cadastrado."
            fi
            
            echo "Pressione ENTER para continuar..."
            read
            ;;

        4)
            echo -e "\n--- 4. Verificação de Arquivos ---"
            echo "Digite o caminho completo do arquivo:"
            read -p "> " nome_arquivo
            
            if [ -f "$nome_arquivo" ]; then
                echo "Resultado: '$nome_arquivo' é um ARQUIVO."
            elif [ -d "$nome_arquivo" ]; then
                echo "Resultado: '$nome_arquivo' é um DIRETÓRIO."
            else
                echo "Inexistente. Criando..."
                touch "$nome_arquivo"
            fi
            
            echo "Pressione ENTER para continuar..."
            read
            ;;

        5)
            echo -e "\n--- 5. Backup Automatizado ---"
            echo "Origem (dir):"
            read -p "> " dir_origem
            echo "Arquivo:"
            read -p "> " arq_origem
            echo "Destino (dir):"
            read -p "> " dir_destino
            
            if [ -f "$dir_origem/$arq_origem" ]; then
                mkdir -p "$dir_destino"
                cp "$dir_origem/$arq_origem" "$dir_destino/"
                echo "Copiado com sucesso."
            else
                echo "Arquivo não encontrado."
            fi
            
            echo "Pressione ENTER para continuar..."
            read
            ;;

        6)
            echo -e "\n--- 6. Busca Inteligente ---"
            echo "Extensão (ex: txt):"
            read -p "> " extensao
            echo "Diretório:"
            read -p "> " dir_busca
            
            if [ -d "$dir_busca" ]; then
                find "$dir_busca" -type f -name "*.$extensao" 2>/dev/null
            else
                echo "Diretório inválido."
            fi
            
            echo "Pressione ENTER para continuar..."
            read
            ;;

        7)
            echo -e "\n--- 7. Loop de Processamento ---"
            ARQ_INFO_MEMBROS="$BASE_DIR/info_membros.txt"
            DIR_MEMBROS="$BASE_DIR/Membros_grupos"
            
            if [ -d "$DIR_MEMBROS" ]; then
                > "$ARQ_INFO_MEMBROS"
                for dir in "$DIR_MEMBROS"/*; do
                    if [ -d "$dir" ]; then
                        NOME_DIR=$(basename "$dir")
                        PERMISSOES=$(stat -c %a "$dir")
                        DATA_CRIACAO=$(stat -c %y "$dir" | cut -d' ' -f1)
                        INFO="Diretório: $NOME_DIR | Permissões: $PERMISSOES | Data: $DATA_CRIACAO"
                        echo "$INFO"
                        echo "$INFO" >> "$ARQ_INFO_MEMBROS"
                    fi
                done
            else
                echo "Execute a opção 1 primeiro."
            fi
            
            echo "Pressione ENTER para continuar..."
            read
            ;;

        8)
            echo "Saindo... Até logo!"
            exit 0 
            ;;
            
        *)
            echo "Opção inválida!"
            echo "Pressione ENTER para tentar novamente..."
            read
            ;;
    esac
done

#!/bin/bash

# ==============================================================================
# Script: gestao_sistema.sh
# Tema: Automação de Rotinas de Administração em Linux
# ==============================================================================

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Por favor, execute este script com sudo: sudo ./gestao_sistema.sh"
    exit 1
fi

# Variável global para o diretório base
BASE_DIR="/home/unip/UnipSolutions"
# Arquivo para registrar os usuários criados no item 2
ARQ_USUARIOS="$BASE_DIR/usuarios_cadastrados.txt"

# Loop infinito para o menu interativo
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
    
    read -p "Escolha uma opção (1-8): " opcao

    case $opcao in
        1)
            echo -e "\n--- 1. Criação de Estrutura de Diretórios ---"
            mkdir -p "$BASE_DIR/Membros_grupos"
            
            read -p "Digite os nomes dos membros separados por VÍRGULA (ex: Joao Silva, Maria, Jose): " entrada_membros
            
            # Salvamos o separador atual e mudamos para vírgula
            OLD_IFS=$IFS
            IFS=','
            
            # O laço agora entende que cada item está separado por vírgula
            for membro in $entrada_membros; do
                # Remove espaços em branco extras no início ou fim do nome (trim)
                membro=$(echo "$membro" | xargs)
                
                # Se o nome não for vazio
                if [ -n "$membro" ]; then
                    # Substitui espaços internos por underline para o nome da pasta (boa prática no Linux)
                    membro_dir="${membro// /_}"
                    DIR_MEMBRO="$BASE_DIR/Membros_grupos/$membro_dir"
                    
                    # mkdir -p evita erros se o nome for repetido (pasta já existe)
                    mkdir -p "$DIR_MEMBRO"
                    echo "Diretório para '$membro' configurado em: $membro_dir"
                fi
            done
            
            # Restauramos o separador original
            IFS=$OLD_IFS
            
            chmod -R 757 "$BASE_DIR"
            echo "Permissões configuradas (757)."
            read -p "Pressione ENTER para continuar..."
            ;;

        2)
            echo -e "\n--- 2. Cadastro de Usuários ---"
            mkdir -p "$BASE_DIR" 
            
            while true; do
                # CORREÇÃO: Removida a aspas extra no final do comando read que causava o erro de sintaxe
                read -p "Digite o nome do novo usuário (ou 'sair'): " nome_usuario
                
                if [ "$nome_usuario" == "sair" ]; then
                    break
                fi

                # Substitui espaços por underline para o login do sistema
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
            read -p "Pressione ENTER para continuar..."
            ;;

        4)
            echo -e "\n--- 4. Verificação de Arquivos ---"
            read -p "Digite o caminho completo do arquivo: " nome_arquivo
            if [ -f "$nome_arquivo" ]; then
                echo "Resultado: '$nome_arquivo' é um ARQUIVO."
            elif [ -d "$nome_arquivo" ]; then
                echo "Resultado: '$nome_arquivo' é um DIRETÓRIO."
            else
                echo "Inexistente. Criando..."
                touch "$nome_arquivo"
            fi
            read -p "Pressione ENTER para continuar..."
            ;;

        5)
            echo -e "\n--- 5. Backup Automatizado ---"
            read -p "Origem (dir): " dir_origem
            read -p "Arquivo: " arq_origem
            read -p "Destino (dir): " dir_destino
            
            if [ -f "$dir_origem/$arq_origem" ]; then
                mkdir -p "$dir_destino"
                cp "$dir_origem/$arq_origem" "$dir_destino/"
                echo "Copiado com sucesso."
            else
                echo "Arquivo não encontrado."
            fi
            read -p "Pressione ENTER para continuar..."
            ;;

        6)
            echo -e "\n--- 6. Busca Inteligente ---"
            read -p "Extensão (ex: txt): " extensao
            read -p "Diretório: " dir_busca
            if [ -d "$dir_busca" ]; then
                find "$dir_busca" -type f -name "*.$extensao" 2>/dev/null
            else
                echo "Diretório inválido."
            fi
            read -p "Pressione ENTER para continuar..."
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
            read -p "Pressione ENTER para continuar..."
            ;;

        8)
            echo "Saindo..."
            exit 0 
            ;;
            
        *)
            echo "Opção inválida!"
            read -p "Pressione ENTER..."
            ;;
    esac
done

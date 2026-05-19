https://imgur.com/a/o3Nu8z3

wget https://pastebin.com/raw/ -O gestao_sistema.sh

---

#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Execute usando sudo"
    exit 1
fi

BASE_DIR="/home/unip/UnipSolutions"
ARQ_USUARIOS="$BASE_DIR/usuarios_cadastrados.txt"

while true; do
    clear
    echo "========================================================="
    echo "         - SISTEMA DE GESTÃO -- UNIP SOLUTIONS -         "
    echo "========================================================="
    echo "1. Criação de Estrutura de Diretórios"
    echo "2. Cadastro de Usuários"
    echo "3. Listagem de usuários e Relatório"
    echo "4. Verificação de Arquivos"
    echo "5. Backup Automatizado"
    echo "6. Busca Inteligente"
    echo "7. Loop de Processamento (Info Membros)"
    echo "8. Deletar Usuários ou Diretórios"
    echo "9. Sair"
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
            echo -e "\n--- 8. Deletar Usuários ou Diretórios ---"
            echo "1. Deletar Usuário"
            echo "2. Deletar Diretório de um Membro"
            echo "Escolha o que deseja fazer (1 ou 2):"
            read -p "> " sub_opcao

            if [ "$sub_opcao" == "1" ]; then
                echo -e "\n[ Lista de Usuários Cadastrados pelo Script ]"
                if [ -f "$ARQ_USUARIOS" ] && [ -s "$ARQ_USUARIOS" ]; then
                    cat "$ARQ_USUARIOS"
                else
                    echo "(Nenhum usuário foi cadastrado ainda)"
                fi
                echo "---------------------------------------------"
                echo "Digite o nome do usuário a ser deletado (ou 'cancelar' para voltar):"
                read -p "> " del_user
                
                if [ "$del_user" != "cancelar" ] && [ -n "$del_user" ]; then
                    if id "$del_user" &>/dev/null; then
                        read -p "Tem a certeza que deseja eliminar o utilizador '$del_user' e a sua pasta pessoal? (s/n): " confirmacao
                        if [[ "$confirmacao" == "s" || "$confirmacao" == "S" ]]; then
                            userdel -r "$del_user" 2>/dev/null
                            echo "Sucesso: O utilizador '$del_user' e a sua pasta pessoal foram removidos."
                            
                            if [ -f "$ARQ_USUARIOS" ]; then
                                sed -i "/^$del_user$/d" "$ARQ_USUARIOS"
                            fi
                        else
                            echo "Operação cancelada."
                        fi
                    else
                        echo "Erro: O utilizador '$del_user' não existe no sistema."
                    fi
                fi
                
            elif [ "$sub_opcao" == "2" ]; then
                DIR_MEMBROS="$BASE_DIR/Membros_grupos"
                echo -e "\n[ Lista de Diretórios de Membros ]"
                if [ -d "$DIR_MEMBROS" ]; then
                    ls -1 "$DIR_MEMBROS" 2>/dev/null
                else
                    echo "(Nenhum membro cadastrado ainda)"
                fi
                echo "---------------------------------------------"
                echo "Digite APENAS o NOME do diretório a ser deletado (ou 'cancelar' para voltar):"
                read -p "> " del_dir
                
                if [ "$del_dir" != "cancelar" ] && [ -n "$del_dir" ]; then
                    caminho_alvo="$DIR_MEMBROS/$del_dir"
                    
                    if [ -d "$caminho_alvo" ]; then
                        if [[ "$del_dir" == *"/"* ]] || [[ "$del_dir" == *".."* ]]; then
                            echo "Erro: Nome de diretório inválido. Digite apenas o nome da pasta."
                        else
                            read -p "Tem a certeza que deseja eliminar o diretório '$del_dir' e todo o seu conteúdo? (s/n): " confirmacao
                            if [[ "$confirmacao" == "s" || "$confirmacao" == "S" ]]; then
                                rm -rf "$caminho_alvo"
                                echo "Sucesso: O diretório do membro '$del_dir' foi removido."
                            else
                                echo "Operação cancelada."
                            fi
                        fi
                    else
                        echo "Erro: O diretório '$del_dir' não foi encontrado na lista de membros."
                    fi
                fi
            else
                echo "Erro: Opção inválida."
            fi
            
            echo "Pressione ENTER para continuar..."
            read
            ;;

        9)
            echo "Saindo..."
            exit 0 
            ;;
            
        *)
            echo "Opção inválida!"
            echo "Pressione ENTER para tentar novamente..."
            read
            ;;
    esac
done

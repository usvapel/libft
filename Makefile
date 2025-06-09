# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jpelline <jpelline@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/08 21:55:46 by jpelline          #+#    #+#              #
#    Updated: 2025/06/09 20:14:38 by jpelline         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Colors and formatting
BOLD		:= $(shell tput bold)
GREEN		:= $(shell tput setaf 2)
YELLOW		:= $(shell tput setaf 3)
BLUE		:= $(shell tput setaf 4)
MAGENTA		:= $(shell tput setaf 5)
CYAN		:= $(shell tput setaf 6)
WHITE		:= $(shell tput setaf 7)
RESET		:= $(shell tput sgr0)

NAME		:= libft.a

# Compiler flags
CC		:= cc
CFLAGS		:= -Wextra -Wall -Werror

# Directories
OBJ_DIR		:= obj
SRC_DIR		:= src

# Dependencies tracking
DEP_DIR		:= $(OBJ_DIR)/.deps
DEPFLAGS	= -MT $@ -MMD -MP -MF $(DEP_DIR)/$*.d

# Include paths
INC		:= -I./include

# Sources
# Character functions
CHAR_SRCS = \
    ft_isalpha.c  ft_isdigit.c  ft_isalnum.c  ft_isascii.c  ft_isprint.c \
    ft_toupper.c  ft_tolower.c

# String manipulation functions
STR_SRCS = \
    ft_strlen.c   ft_strlcpy.c  ft_strlcat.c  ft_strchr.c   ft_strrchr.c \
    ft_strncmp.c  ft_strnstr.c  ft_strdup.c   ft_substr.c   ft_strjoin.c \
    ft_strtrim.c  ft_split.c    ft_strmapi.c  ft_striteri.c ft_reverse_string.c

# Memory management functions  
MEM_SRCS = \
    ft_memset.c   ft_bzero.c    ft_memcpy.c   ft_memmove.c  ft_memchr.c \
    ft_memcmp.c   ft_calloc.c

# File descriptor operations
FD_SRCS = \
    ft_putchar_fd.c  ft_putstr_fd.c  ft_putendl_fd.c  ft_putnbr_fd.c  ft_uputnbr_fd.c

# Conversion functions
CONV_SRCS = \
    ft_atoi.c  ft_itoa.c  ft_printf.c

# Linked list functions
LST_SRCS = \
    ft_lstnew_bonus.c      ft_lstadd_front_bonus.c  ft_lstsize_bonus.c \
    ft_lstlast_bonus.c     ft_lstadd_back_bonus.c   ft_lstdelone_bonus.c \
    ft_lstclear_bonus.c    ft_lstiter_bonus.c       ft_lstmap_bonus.c

# All source files
SRCS = $(CHAR_SRCS) $(STR_SRCS) $(MEM_SRCS) $(FD_SRCS) $(CONV_SRCS) $(LST_SRCS)

# Objects
OBJS		:= $(addprefix $(OBJ_DIR)/,$(SRCS:.c=.o))
TOTAL_SRCS	:= $(words $(SRCS))

# Files to track build
MARKER_STANDARD := .standard_build

# Variables for progress tracking
LAST_PERCENTAGE := 0
COMPILED_COUNT	:= 0

# Code to check if program is up to date, used in all target
is_up_to_date = \
    [ -f $(NAME) ] && \
    [ -z "$$(find $(SRC_DIR) -name '*.c' -newer $(NAME) 2>/dev/null)" ]

# Default target / checks if rebuild is needed
all:
	@if [ -f $(NAME) ] && [ -f $(MARKER_STANDARD) ] && $(is_up_to_date) 2>/dev/null; then \
		echo "$(BOLD)$(YELLOW)🔄 $(NAME) is already up to date.$(RESET)"; \
	else \
		echo "$(BOLD)$(WHITE)🌀 Starting to build $(NAME)...$(RESET)"; \
		$(MAKE) $(NAME) --no-print-directory; \
		touch $(MARKER_STANDARD); \
		echo "$(BOLD)$(GREEN)✅ All components built successfully!$(RESET)"; \
	fi

# Main executable target - links all objects and libraries
$(NAME): $(OBJS)
	@echo "✅ $(BOLD)$(GREEN)All files compiled successfully!$(RESET)"
	@echo "$(BOLD)$(GREEN)🔗 Linking $(NAME)...$(RESET)"
	@ar rcs $@ $^
	@touch $(MARKER_STANDARD)
	@echo "$(BOLD)$(GREEN)✅ $(NAME) successfully compiled!$(RESET)"

# Create necessary directories if they don't exist
$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

$(DEP_DIR):
	@mkdir -p $@

# Compilation rule for each source file
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR) $(DEP_DIR)
	$(eval COMPILED_COUNT := $(shell echo $$(($(COMPILED_COUNT)+1))))
	$(eval PROGRESS := $(shell echo $$(($(COMPILED_COUNT)*100/$(TOTAL_SRCS)))))
	@if [ $$(($(PROGRESS) % 1)) -eq 0 ] || [ $(PROGRESS) -eq 100 ]; then \
		printf "🔧 [%3d%%] $(BOLD)$(BLUE)Compiling... (%d/%d files)$(RESET)\n" \
			$(PROGRESS) $(COMPILED_COUNT) $(TOTAL_SRCS); \
	fi
	@$(CC) $(CFLAGS) $(DEPFLAGS) -c $< -o $@ $(INC)

# Include auto-generated dependency files
-include $(wildcard $(DEP_DIR)/*.d)

# Remove object files and dependency files
clean:
	@if [ -d $(OBJ_DIR) ]; then \
		echo "[ clean  ] $(YELLOW)🧹 Cleaning object files...$(RESET)"; \
		rm -rf $(OBJ_DIR); \
		echo "[ clean  ] $(YELLOW)✅ Object files cleaned!$(RESET)"; \
	else \
		echo "[ clean  ] $(BOLD)$(YELLOW)🧹 Nothing to be done...$(RESET)"; \
	fi

# Remove everything including the executable
fclean: clean
	@if [ -f $(NAME) ]; then \
		echo "[ fclean ] $(YELLOW)🧹 Removing $(NAME)...$(RESET)"; \
		rm -rf $(NAME); \
		rm -f $(MARKER_STANDARD); \
		echo "[ fclean ] $(YELLOW)✅ $(NAME) removed!$(RESET)"; \
	else \
		echo "[ fclean ] $(BOLD)$(YELLOW)🧹 Nothing to be done...$(RESET)"; \
	fi

# Full rebuild from scratch
re: fclean
	@echo "[ re     ] $(BOLD)$(WHITE)🔄 Rebuilding from scratch...$(RESET)"
	@$(MAKE) all --no-print-directory

# Prevent intermediate files from being deleted
.SECONDARY: $(OBJS)
.PHONY: all clean fclean re

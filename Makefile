APP_NAME = geometry
LIB_NAME = libgeometry
TEST_NAME = test

CFLAGS = -Wall -Wno-unknown-pragmas
CPPFLAGS = -I src -MP -MMD
LDFLAGS =
LDLIBS = -lm
LSTFLAGS =

BIN_DIR = bin
OBJ_DIR = obj
SRC_DIR = src
TEST_DIR = tests

TEST_PATH = $(BIN_DIR)/$(TEST_NAME).out
APP_PATH = $(BIN_DIR)/$(APP_NAME).out
LIB_PATH = $(OBJ_DIR)/$(SRC_DIR)/$(LIB_NAME)/$(LIB_NAME).a

SRC_EXT = c

APP_SOURCES = $(shell find $(SRC_DIR)/$(APP_NAME) -name '*.$(SRC_EXT)')
APP_OBJECTS = $(APP_SOURCES:$(SRC_DIR)/%.$(SRC_EXT)=$(OBJ_DIR)/$(SRC_DIR)/%.o)

LIB_SOURCES = $(shell find $(SRC_DIR)/$(LIB_NAME) -name '*.$(SRC_EXT)')
LIB_OBJECTS = $(LIB_SOURCES:$(SRC_DIR)/%.$(SRC_EXT)=$(OBJ_DIR)/$(SRC_DIR)/%.o)

TEST_SOURCES = $(shell find $(TEST_DIR)/ -name '*.$(SRC_EXT)')
TEST_OBJECTS = $(TEST_SOURCES:$(TEST_DIR)/%.$(SRC_EXT)=$(OBJ_DIR)/$(TEST_DIR)/%.o)

DEPS = $(APP_OBJECTS:.o=.d) $(LIB_OBJECTS:.o=.d) $(TEST_OBJECTS:.o=.d) 

.PHONY: all lib test
all: $(APP_PATH)

-include $(DEPS)

$(APP_PATH): $(APP_OBJECTS) $(LIB_PATH)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@ $(LDFLAGS) $(LDLIBS) $(LSTFLAGS)

$(LIB_PATH): $(LIB_OBJECTS)
	ar rcs $@ $^

$(OBJ_DIR)/$(SRC_DIR)/$(APP_NAME)/%.o: $(SRC_DIR)/$(APP_NAME)/%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@ $(LSTFLAGS)

$(OBJ_DIR)/$(SRC_DIR)/$(LIB_NAME)/%.o: $(SRC_DIR)/$(LIB_NAME)/%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@ $(LSTFLAGS)

lib: $(LIB_PATH)

test: $(TEST_SOURCES) $(TEST_PATH)

$(TEST_PATH): $(TEST_OBJECTS) 
	$(CC) -I thirdparty/ -MP -MMD $(TEST_OBJECTS) -o $@ $(LDFLAGS) $(LDLIBS) $(LSTFLAGS)

$(OBJ_DIR)/$(TEST_DIR)/%.o: $(TEST_DIR)/%.c
	$(CC) -c $(CFLAGS) -I thirdparty/ -MP -MMD $< -o $@ $(LDFLAGS) $(LDLIBS) $(LSTFLAGS)

.PHONY: clean
clean:
	$(RM) $(APP_PATH) $(LIB_PATH)
	find $(OBJ_DIR) -name '*.o' -exec $(RM) '{}' \;
	find $(OBJ_DIR) -name '*.d' -exec $(RM) '{}' \;
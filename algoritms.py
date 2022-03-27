import traceback
from re import fullmatch, finditer

class TestRunner(object):
    def __init__(self, name):
        self.name = name
        self.testNo = 1

    def expectTrue(self, cond):
        try:
            if cond():
                self._pass()
            else:
                self._fail()
        except Exception as e:
            self._fail(e)

    def expectFalse(self, cond):
        self.expectTrue(lambda: not cond())

    def expectException(self, block):
        try:
            block()
            self._fail()
        except:
            self._pass()

    def _fail(self, e=None):
        print(f'FAILED: Test  # {self.testNo} of {self.name}')
        self.testNo += 1
        if e is not None:
            traceback.print_tb(e.__traceback__)

    def _pass(self):
        print(f'PASSED: Test  # {self.testNo} of {self.name}')
        self.testNo += 1


def match_symb_and_regx(patt: str, string: str, simbol: chr, reg: str) -> bool:
    """ Функция проверяет соответствует ли символ регулярному выражению """
    #список с индексами вхождения символа в патерне
    character_indices = [_.start() for _ in finditer(simbol, patt)]
    flag = True

    for i in character_indices:
        if fullmatch(reg, string[i]):
            flag = flag and True
        else:
            flag = flag and False
    return flag 

def match(string, pattern):
    #проверка патерна на наличие неразрешённых символов
    if [i for i in pattern if i not in ('a', '*', 'd', ' ')]:
        raise Exception('Wrong pattern')

    if len(string) == len(pattern):
            return (
            match_symb_and_regx(pattern, string, 'd', '[0-9]') and 
            match_symb_and_regx(pattern, string, 'a', '[a-z]') and 
            match_symb_and_regx(pattern, string, '\*', '[a-z0-9]') and 
            match_symb_and_regx(pattern, string, ' ', ' '))
    else:
        return False


def testMatch():
    runner = TestRunner('match')

    runner.expectFalse(lambda: match('xy', 'a'))
    runner.expectFalse(lambda: match('x', 'd'))
    runner.expectFalse(lambda: match('0', 'a'))
    runner.expectFalse(lambda: match('*', ' '))
    runner.expectFalse(lambda: match(' ',  'a'))

    runner.expectTrue(lambda:  match('01 xy', 'dd aa'))
    runner.expectTrue(lambda: match('1x', '**'))

    runner.expectException(lambda:  match('x', 'w'))


tasks = {
    'id': 0,
    'name': 'Все задачи',
    'children': [
        {
            'id': 1,
            'name': 'Разработка',
            'children': [
                {'id': 2, 'name': 'Планирование разработок', 'priority': 1},
                {'id': 3, 'name': 'Подготовка релиза', 'priority': 4},
                {'id': 4, 'name': 'Оптимизация', 'priority': 2},
            ],
        },
        {
            'id': 5,
            'name': 'Тестирование',
            'children': [
                {
                    'id': 6,
                    'name': 'Ручное тестирование',
                    'children': [
                        {'id': 7, 'name': 'Составление тест-планов', 'priority': 3},
                        {'id': 8, 'name': 'Выполнение тестов', 'priority': 6},
                    ],
                },
                {
                    'id': 9,
                    'name': 'Автоматическое тестирование',
                    'children': [
                        {'id': 10, 'name': 'Составление тест-планов', 'priority': 3},
                        {'id': 11, 'name': 'Написание тестов', 'priority': 3},
                    ],
                },
            ],
        },
        {'id': 12, 'name': 'Аналитика', 'children': []},
    ],
}



def find_node(tasks: list, groupId: int, node: list) -> dict:
    """ Функция ищет группу по заданному id и возвращает её"""
    for elem in tasks:
        if elem['id'] == groupId and 'children' not in elem.keys():
            raise Exception('Is not a group')
        elif elem['id'] == groupId and not elem['children']:
            return None
        elif elem['id'] == groupId:
            node.append(elem)
        elif 'children' not in elem.keys():
            pass
        else:
            find_node(elem['children'], groupId, node)
    return node


def find_tasks(group: list, task_list: list) -> list:
    """ Функция возвращает все задачи, которые находятся в группе (включая вложенные)"""
    for elem in group:
        if 'children' not in elem.keys():
            task_list.append(elem)
        else:
             find_tasks(elem['children'], task_list)
    
    return task_list
    
def task_max_priority(group: dict) -> dict:
    """ Из списка тасков функция возвращает задачу с максимальным приоритетом """
    tasks = find_tasks(group['children'], [])

    max_priority = sorted(map(lambda x: x['priority'], tasks), reverse= True)[0]

    return next(elem for elem in tasks if elem['priority'] == max_priority)


def findTaskHavingMaxPriorityInGroup(tasks, groupId):
    #обработка случая, когда groupId является корнем дерева
    if groupId == tasks['id']:
        return task_max_priority(tasks)

    group = find_node(tasks['children'], groupId, [])

    if group is None:
        return None
    if not group:
        raise Exception("No such group exists")

    return task_max_priority(group[0])



def taskEquals(a, b):
    return (
        not 'children' in a and
        not 'children' in b and
        a['id'] == b['id'] and
        a['name'] == b['name'] and
        a['priority'] == b['priority']
    )


def testFindTaskHavingMaxPriorityInGroup():
    runner = TestRunner('findTaskHavingMaxPriorityInGroup')

    runner.expectException(lambda: findTaskHavingMaxPriorityInGroup(tasks, 13))
    runner.expectException(lambda: findTaskHavingMaxPriorityInGroup(tasks, 2))
    runner.expectTrue(lambda: findTaskHavingMaxPriorityInGroup(tasks, 12) is None)
    runner.expectTrue(lambda: findTaskHavingMaxPriorityInGroup(tasks, 9)['priority'] == 3)
    runner.expectTrue(lambda: taskEquals(findTaskHavingMaxPriorityInGroup(tasks, 1), {
        'id': 3,
        'name': 'Подготовка релиза',
        'priority': 4,
    }))
    runner.expectTrue(lambda: taskEquals(findTaskHavingMaxPriorityInGroup(tasks, 0), {
        'id': 8,
        'name': 'Выполнение тестов',
        'priority': 6,
    }))
    


testMatch()
testFindTaskHavingMaxPriorityInGroup()
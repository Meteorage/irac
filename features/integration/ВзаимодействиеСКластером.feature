
# language: ru

Функционал: Взаимодействие с кластером серверов
    Как Администратор кластера
    Я хочу програмно управлять кластером серверов
    Чтобы что бы автоматизировать развертывание инфраструктуры 1С

Контекст:
    Когда Я подключаюсь с сервису администрирования кластера по адресу "ras"

Сценарий: Создание информационной базы
    Когда Я вызываю функцию создания информационной базы с именем "IRAC_TEST1" в кластере "server"
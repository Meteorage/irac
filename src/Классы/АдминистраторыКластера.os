// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера   - ссылка на родительский объект агента кластера
//   Кластер            - Кластер         - ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Лог = Служебный.Лог();

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Кластер_Агент, Перечисления.РежимыАдминистрирования.АдминистраторыКластера);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список администраторов кластера 1С от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   РежимОбновления           - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                              0 - обновить данные только по таймеру
//                                             -1 - не обновлять данные
//   
Процедура ОбновитьДанные(РежимОбновления = 0) Экспорт

	Если НЕ ТребуетсяОбновление(РежимОбновления) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Список");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка администраторов кластера, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивАдминистраторов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		Администратор = Новый ОбъектКластера(Кластер_Агент,
		                                     Кластер_Владелец,
		                                     Перечисления.РежимыАдминистрирования.АдминистраторыКластера,
		                                     ТекОписание);
		МассивАдминистраторов.Добавить(Администратор);
	КонецЦикла;

	Элементы.Заполнить(МассивАдминистраторов);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   РежимОбновления           - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                              0 - обновить данные только по таймеру
//                                             -1 - не обновлять данные
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(РежимОбновления = 0) Экспорт

	Возврат Элементы.ТребуетсяОбновление(РежимОбновления);

КонецФункции // ТребуетсяОбновление()

// Функция возвращает описание параметров объекта
//   
// Возвращаемое значение:
//    КомандыОбъекта - описание параметров объекта,
//
Функция ПараметрыОбъекта() Экспорт

	Возврат ПараметрыОбъекта;

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список администраторов кластера
//   
// Параметры:
//   Отбор                     - Структура    - Структура отбора администраторов (<поле>:<значение>)
//   РежимОбновления           - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                              0 - обновить данные только по таймеру
//                                             -1 - не обновлять данные
//   ЭлементыКакСоответствия   - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                               Строка         с именами свойств в качестве ключей
//                                              <Имя поля> - элементы результата будут преобразованы в соответствия
//                                              со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                              Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список администраторов кластера 1С
//
Функция Список(Отбор = Неопределено, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.Список(Отбор, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // Список()

// Функция возвращает список администраторов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка       - Поля для построения иерархии списка администраторов, разделенные ","
//   РежимОбновления          - Число        - 1 - обновить данные принудительно (вызов RAC)
//                                             0 - обновить данные только по таймеру
//                                            -1 - не обновлять данные
//   ЭлементыКакСоответствия  - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                              Строка         с именами свойств в качестве ключей
//                                             <Имя поля> - элементы результата будут преобразованы в соответствия
//                                             со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                             Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список администраторов кластеров 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список администраторов или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, РежимОбновления = 0, ЭлементыКакСоответствия = Ложь) Экспорт

	Возврат Элементы.ИерархическийСписок(ПоляИерархии, РежимОбновления, ЭлементыКакСоответствия);

КонецФункции // ИерархическийСписок()

// Функция возвращает количество администраторов кластера в списке
//   
// Возвращаемое значение:
//    Число - количество администраторов кластера
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание администратора кластера 1С
//   
// Параметры:
//   Имя                     - Строка    - Имя администраторов кластера
//   РежимОбновления         - Число     - 1 - обновить данные принудительно (вызов RAC)
//                                         0 - обновить данные только по таймеру
//                                        -1 - не обновлять данные
//   КакСоответствие         - Булево    - Истина - результат будет преобразован в соответствие
//
// Возвращаемое значение:
//    Соответствие - описание администратора кластера 1С
//
Функция Получить(Знач Имя, Знач РежимОбновления = 0, КакСоответствие = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("name", Имя);
	
	АдминистраторыКластера = Элементы.Список(Отбор, РежимОбновления, КакСоответствие);
	
	Если НЕ ЗначениеЗаполнено(АдминистраторыКластера) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат АдминистраторыКластера[0];

КонецФункции // Получить()

// Процедура добавляет нового администратора кластера
//   
// Параметры:
//    Имя                            - Строка        - имя администратора кластера 1С
//    ПараметрыАдминКластера        - Структура        - параметры создаваемого администратора
//        - Пароль                    - Строка        - пароль администратора кластера 1С
//        - Описание                    - Строка        - описание администратора кластера 1С
//        - СпособАвторизации            - Строка        - Пароль / пользователь ОС
//        - ПользовательОС            - Строка    - пользователь ОС, соответствующий администратору
//    УстановитьТекущим             - Булево        - Истина - сделать добавленного администратора
//                                                  текущим для кластера
//
Процедура Добавить(Знач Имя, Знач ПараметрыАдминКластера = Неопределено, УстановитьТекущим = Ложь) Экспорт

	Если НЕ ТипЗнч(ПараметрыАдминКластера) = Тип("Структура") Тогда
		ПараметрыАдминКластера = Новый Структура();
	КонецЕсли;

	ТекущееКоличество = Количество();

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииАгента"  , Кластер_Агент.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("Имя"                    , Имя);

	Для Каждого ТекЭлемент Из ПараметрыАдминКластера Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Добавить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления администратора кластера ""%1"", КодВозврата = %2: %3",
	                                Имя,
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Если УстановитьТекущим ИЛИ ТекущееКоличество = 0 Тогда
		Кластер_Владелец.УстановитьАдминистратора(Имя, ПараметрыАдминКластера.Пароль);
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Добавить()

// Процедура удаляет администратора кластера
//   
// Параметры:
//   Имя                 - Строка        - имя администратора кластера 1С
//
Процедура Удалить(Имя) Экспорт

	ТекущееКоличество = Количество();

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("Имя"                    , Имя);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = ПараметрыОбъекта.ВыполнитьКоманду("Удалить");

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления администратора кластера ""%1"", КодВозврата = %2: %3",
	                                Имя,
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Если ТекущееКоличество = 1 Тогда
		Кластер_Владелец.УстановитьАдминистратора("", "");
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Перечисления.РежимыОбновленияДанных.Принудительно);

КонецПроцедуры // Удалить()
